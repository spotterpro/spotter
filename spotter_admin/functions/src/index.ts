import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";

import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import axios from "axios";

initializeApp();

const KAKAO_API_KEY = process.env.KAKAO_KEY;

export const geocodeAddressOnCreate = onDocumentCreated(
  {
    document: "store_applications/{applicationId}",
    region: "asia-northeast3", // 서울 리전
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      logger.log("이벤트 데이터가 없으므로 함수를 종료합니다.");
      return;
    }

    const data = snapshot.data();

    if (!data || !data.address) {
      logger.log("주소가 없으므로 함수를 종료합니다.", {
        applicationId: event.params.applicationId,
      });
      return;
    }

    const address = data.address;
    logger.log(`지오코딩 시작: ${address}`, {
      applicationId: event.params.applicationId,
    });

    try {
      if (!KAKAO_API_KEY) {
        throw new Error("카카오 API 키가 설정되지 않았습니다.");
      }

      // 'dapi.ao.com' -> 'dapi.kakao.com' 으로 오타 수정했습니다, 형님.
      const response = await axios.get(
        "https://dapi.kakao.com/v2/local/search/address.json",
        {
          params: { query: address },
          headers: { Authorization: `KakaoAK ${KAKAO_API_KEY}` },
        }
      );

      if (response.data.documents && response.data.documents.length > 0) {
        const location = response.data.documents[0];
        const latitude = parseFloat(location.y);
        const longitude = parseFloat(location.x);

        logger.log(`지오코딩 성공: 위도 ${latitude}, 경도 ${longitude}`, {
          applicationId: event.params.applicationId,
        });

        await getFirestore().collection("storeApplications").doc(event.params.applicationId).update({
          latitude: latitude,
          longitude: longitude,
        });
      } else {
        logger.warn("주소에 해당하는 좌표를 찾을 수 없습니다.", { address });
        await getFirestore().collection("storeApplications").doc(event.params.applicationId).update({
          geocodeError: "ADDRESS_NOT_FOUND",
        });
      }
    } catch (error) {
      logger.error("지오코딩 프로세스 중 에러 발생", {
        error,
        applicationId: event.params.applicationId,
      });
      await getFirestore().collection("storeApplications").doc(event.params.applicationId).update({
        geocodeError: "API_CALL_FAILED",
      });
    }
  }
);