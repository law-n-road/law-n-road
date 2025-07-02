package com.lawnroad.account.mapper;


import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface LawyerPointMapper {
  
  // 포인트 증감 (음수도 허용)
  int updatePoint(@Param("lawyerNo") Long lawyerNo, @Param("amount") int amount);
  
  // 매달 1일에 모든 변호사의 point를 0으로
  @Update("UPDATE lawyer SET point = 0")
  int resetAllPoints();
}
