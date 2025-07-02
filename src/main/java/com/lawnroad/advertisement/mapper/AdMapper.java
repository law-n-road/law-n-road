package com.lawnroad.advertisement.mapper;

import com.lawnroad.advertisement.dto.AdRegisterDto;
import com.lawnroad.advertisement.dto.AdvertisementDetailResponseDto;
import com.lawnroad.advertisement.dto.AdvertisementListResponseDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

@Mapper
public interface AdMapper {
  // 전체조회
  List<AdvertisementListResponseDto> selectAdsByUserWithPaging(
      @Param("userNo") Long userNo,
      @Param("offset") int offset,
      @Param("limit") int limit);
  
  int countAdsByUser(@Param("userNo") Long userNo);
  
  // 상세조회
  AdvertisementDetailResponseDto selectAdDetailByAdNo(Long adNo);
  
  // 광고 등록
  void insertAd(AdRegisterDto dto);
  
  // 삭제 메서드
  void deleteAd(@Param("adNo") Long adNo);

  @Update("UPDATE ad_purchase SET ad_status = 0 WHERE ad_status = 1 AND end_date < CURDATE()")
  void releaseClientStop();


}
