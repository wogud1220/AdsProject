from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api import deps
from app.crud import crud_store
from app.schemas.store import StoreCreate, StoreUpdate, StoreResponse
from app.models.user import User

router = APIRouter()


@router.post("/", response_model=StoreResponse, status_code=status.HTTP_201_CREATED)
def create_store(
    *,
    db: Session = Depends(deps.get_db),
    store_in: StoreCreate,
    current_user: User = Depends(deps.get_current_user)
):
    """
    가게 등록 - 현재 로그인한 사용자의 가게로 생성
    """
    store = crud_store.create(db, obj_in=store_in, user_id=current_user.id)
    return store


@router.get("/", response_model=List[StoreResponse])
def read_stores(
    db: Session = Depends(deps.get_db),
    skip: int = 0,
    limit: int = 100,
    current_user: User = Depends(deps.get_current_user)
):
    """
    내 가게 목록 조회 - 현재 로그인한 사용자의 가게만
    """
    stores = crud_store.get_by_user(db, user_id=current_user.id)
    return stores


@router.get("/{store_id}", response_model=StoreResponse)
def read_store(
    *,
    db: Session = Depends(deps.get_db),
    store_id: int,
    current_user: User = Depends(deps.get_current_user)
):
    """
    특정 가게 상세 조회 - 본인 가게만 접근 가능
    """
    store = crud_store.get_by_user_and_id(
        db, user_id=current_user.id, store_id=store_id
    )
    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="가게를 찾을 수 없거나 접근 권한이 없습니다."
        )
    return store


@router.put("/{store_id}", response_model=StoreResponse)
def update_store(
    *,
    db: Session = Depends(deps.get_db),
    store_id: int,
    store_in: StoreUpdate,
    current_user: User = Depends(deps.get_current_user)
):
    """
    가게 정보 수정 - 본인 가게만 수정 가능
    """
    store = crud_store.get_by_user_and_id(
        db, user_id=current_user.id, store_id=store_id
    )
    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="가게를 찾을 수 없거나 접근 권한이 없습니다."
        )
    
    store = crud_store.update(db, db_obj=store, obj_in=store_in)
    return store


@router.delete("/{store_id}", response_model=StoreResponse)
def delete_store(
    *,
    db: Session = Depends(deps.get_db),
    store_id: int,
    current_user: User = Depends(deps.get_current_user)
):
    """
    가게 삭제 - 본인 가게만 삭제 가능
    """
    store = crud_store.remove_by_user_and_id(
        db, user_id=current_user.id, store_id=store_id
    )
    if not store:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="가게를 찾을 수 없거나 접근 권한이 없습니다."
        )
    return store
