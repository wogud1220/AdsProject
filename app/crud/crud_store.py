from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import List, Optional

from app.models.store import Store as StoreModel
from app.models.user import User as UserModel
from app.schemas.store import StoreCreate, StoreUpdate


class CRUDStore:
    def create(self, db: Session, *, obj_in: StoreCreate, user_id: int) -> StoreModel:
        """
        가게 생성 - 현재 로그인한 사용자의 ID를 자동 할당
        """
        db_obj = StoreModel(
            **obj_in.dict(),
            user_id=user_id
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def get_by_user(self, db: Session, *, user_id: int) -> List[StoreModel]:
        """
        특정 사용자의 모든 가게 목록 조회
        """
        return db.query(StoreModel).filter(StoreModel.user_id == user_id).all()

    def get_by_user_and_id(self, db: Session, *, user_id: int, store_id: int) -> Optional[StoreModel]:
        """
        특정 사용자의 특정 가게 조회 (권한 체크용)
        """
        return (
            db.query(StoreModel)
            .filter(and_(StoreModel.user_id == user_id, StoreModel.id == store_id))
            .first()
        )

    def get_multi(self, db: Session, *, skip: int = 0, limit: int = 100) -> List[StoreModel]:
        """
        모든 가게 목록 조회 (관리자용)
        """
        return db.query(StoreModel).offset(skip).limit(limit).all()

    def get(self, db: Session, id: int) -> Optional[StoreModel]:
        """
        ID로 가게 조회
        """
        return db.query(StoreModel).filter(StoreModel.id == id).first()

    def update(
        self, db: Session, *, db_obj: StoreModel, obj_in: StoreUpdate
    ) -> StoreModel:
        """
        가게 정보 수정 (본인 권한 체크 후 호출)
        """
        update_data = obj_in.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_obj, field, value)
        
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def remove(self, db: Session, *, id: int) -> StoreModel:
        """
        가게 삭제 (본인 권한 체크 후 호출)
        """
        obj = db.query(StoreModel).get(id)
        db.delete(obj)
        db.commit()
        return obj

    def remove_by_user_and_id(self, db: Session, *, user_id: int, store_id: int) -> Optional[StoreModel]:
        """
        사용자 권한으로 가게 삭제
        """
        obj = self.get_by_user_and_id(db, user_id=user_id, store_id=store_id)
        if obj:
            db.delete(obj)
            db.commit()
        return obj


# Create a singleton instance
crud_store = CRUDStore()
