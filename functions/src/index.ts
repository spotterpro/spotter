// 📁 functions/src/index.ts

import {onDocumentWritten, onDocumentDeleted} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

// Firebase Admin SDK 초기화
admin.initializeApp();

// =========================================================================
// 임무 1: 데이터 생성/수정 시 키워드('꼬리표') 자동 생성
// =========================================================================

/**
 * 가게(stores) 데이터가 생성/수정될 때마다 키워드를 자동 생성하는 비서
 */
export const generateStoreKeywords = onDocumentWritten(
    {document: "stores/{storeId}", region: "asia-northeast3"},
    async (event) => {
      if (!event.data) {
        console.log("generateStoreKeywords: 이벤트 데이터가 없어 작업을 중단합니다.");
        return;
      }
      const {after} = event.data;
      if (!after.exists) return;

      const data = after.data();
      if (!data || !data.storeName) return;

      const keywords = new Set<string>();
      const storeName = data.storeName.toLowerCase();
      keywords.add(storeName);
      storeName.split(" ").forEach((word: string) => {
        if (word) keywords.add(word);
      });
      if (data.category) {
        keywords.add(data.category.toLowerCase());
      }
      if (data.address) {
        data.address.split(" ").forEach((word: string) => {
          if (word.endsWith("동") || word.endsWith("로") || word.endsWith("길")) {
            keywords.add(word);
          }
        });
      }
      if (data.tags && Array.isArray(data.tags)) {
        data.tags.forEach((tag: string) => {
          keywords.add(tag.replace("#", "").toLowerCase());
        });
      }
      return after.ref.set({keywords: Array.from(keywords)}, {merge: true});
    },
);

/**
 * (참고) 게시물(posts) 데이터용 키워드 생성 비서. 현재는 사용하지 않으므로 주석 처리.
 * 필요시 주석을 해제하여 배포할 수 있습니다.
 */
/*
export const generatePostKeywords = onDocumentWritten(
    {document: "posts/{postId}", region: "asia-northeast3"},
    async (event) => {
      if (!event.data) {
        console.log("generatePostKeywords: 이벤트 데이터가 없어 작업을 중단합니다.");
        return;
      }
      const {after} = event.data;
      if (!after.exists) return;

      const data = after.data();
      if (!data) return;

      const keywords = new Set<string>();

      if (data.caption) {
        data.caption.toLowerCase().split(" ").forEach((word: string) => {
          if (word.length > 1) keywords.add(word);
        });
      }

      if (data.tags && Array.isArray(data.tags)) {
        data.tags.forEach((tag: string) => {
          keywords.add(tag.replace("#", "").toLowerCase());
        });
      }

      if (data.storeName) {
        keywords.add(data.storeName.toLowerCase());
      }

      return after.ref.set({keywords: Array.from(keywords)}, {merge: true});
    },
);
*/


// =========================================================================
// 임무 2: 가게 데이터 삭제 시 하위 데이터 및 '관련 게시물' 연쇄 삭제
// =========================================================================
export const onDeleteStore = onDocumentDeleted(
    {document: "stores/{storeId}", region: "asia-northeast3"},
    async (event) => {
      const storeId = event.params.storeId;
      const db = admin.firestore();
      console.log(`[${storeId}] 가게 삭제 감지. 연쇄 삭제를 시작합니다.`);

      // --- START: ★★★ 게시물 삭제 로직 ★★★ ---
      // 가게가 삭제될 때, 해당 storeId를 가진 모든 종류의 게시물을 함께 삭제합니다.
      const postCollections = ["posts", "community_posts", "owner_posts"];

      const postDeletePromises = postCollections.map(async (collection) => {
        const postsToDelete = await db.collection(collection)
            .where("storeId", "==", storeId).get();

        if (postsToDelete.empty) {
          console.log(`[${storeId}] >> '${collection}'에 관련 게시물이 없습니다.`);
          return;
        }

        console.log(`[${storeId}] >> '${collection}'에서 ${postsToDelete.size}개의 관련 게시물을 삭제합니다.`);
        const batch = db.batch();
        postsToDelete.forEach((doc) => batch.delete(doc.ref));
        return batch.commit();
      });
      // --- END: ★★★ 게시물 삭제 로직 ★★★ ---

      // 기존 하위 컬렉션 삭제 로직
      const subcollectionsToDelete = [
        'rewards', 'regulars', 'nfc_tags',
      ];
      const subcollectionDeletePromises = subcollectionsToDelete.map((collection) =>
        deleteCollection(`stores/${storeId}/${collection}`, 100)
      );

      try {
        // 모든 삭제 작업을 동시에 실행
        await Promise.all([
            ...postDeletePromises,
            ...subcollectionDeletePromises,
        ]);
        console.log(`[${storeId}] 가게의 모든 하위 데이터 및 관련 게시물 삭제 완료.`);
      } catch (error) {
        console.error(`[${storeId}] 연쇄 삭제 중 오류 발생:`, error);
      }
    },
);

// --- 헬퍼 함수들 ---
async function deleteCollection(collectionPath: string, batchSize: number): Promise<void> {
  const collectionRef = admin.firestore().collection(collectionPath);
  const query = collectionRef.orderBy("__name__").limit(batchSize);
  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve).catch(reject);
  });
}
async function deleteQueryBatch(
    query: admin.firestore.Query,
    resolve: (value: void | PromiseLike<void>) => void,
) {
  const snapshot = await query.get();
  if (snapshot.size === 0) {
    resolve();
    return;
  }
  const batch = admin.firestore().batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();
  process.nextTick(() => {
    deleteQueryBatch(query, resolve);
  });
}