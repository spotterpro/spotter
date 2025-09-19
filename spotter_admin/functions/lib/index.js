"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.geocodeAddressOnCreate = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const logger = __importStar(require("firebase-functions/logger"));
const app_1 = require("firebase-admin/app");
const firestore_2 = require("firebase-admin/firestore");
const axios_1 = __importDefault(require("axios"));
(0, app_1.initializeApp)();
const KAKAO_API_KEY = process.env.KAKAO_KEY;
exports.geocodeAddressOnCreate = (0, firestore_1.onDocumentCreated)({
    document: "store_Applications/{applicationId}",
    region: "asia-northeast3", // 서울 리전
}, async (event) => {
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
        const response = await axios_1.default.get("https://dapi.kakao.com/v2/local/search/address.json", {
            params: { query: address },
            headers: { Authorization: `KakaoAK ${KAKAO_API_KEY}` },
        });
        if (response.data.documents && response.data.documents.length > 0) {
            const location = response.data.documents[0];
            const latitude = parseFloat(location.y);
            const longitude = parseFloat(location.x);
            logger.log(`지오코딩 성공: 위도 ${latitude}, 경도 ${longitude}`, {
                applicationId: event.params.applicationId,
            });
            await (0, firestore_2.getFirestore)().collection("storeApplications").doc(event.params.applicationId).update({
                latitude: latitude,
                longitude: longitude,
            });
        }
        else {
            logger.warn("주소에 해당하는 좌표를 찾을 수 없습니다.", { address });
            await (0, firestore_2.getFirestore)().collection("storeApplications").doc(event.params.applicationId).update({
                geocodeError: "ADDRESS_NOT_FOUND",
            });
        }
    }
    catch (error) {
        logger.error("지오코딩 프로세스 중 에러 발생", {
            error,
            applicationId: event.params.applicationId,
        });
        await (0, firestore_2.getFirestore)().collection("storeApplications").doc(event.params.applicationId).update({
            geocodeError: "API_CALL_FAILED",
        });
    }
});
//# sourceMappingURL=index.js.map