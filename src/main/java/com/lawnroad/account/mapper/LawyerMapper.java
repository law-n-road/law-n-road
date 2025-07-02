package com.lawnroad.account.mapper;

import com.lawnroad.account.dto.LawyerDTO;
import com.lawnroad.account.entity.ClientEntity;
import com.lawnroad.account.entity.LawyerEntity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;
import java.util.Map;

@Mapper
public interface LawyerMapper {

    int countByLawyerId1(@Param("lawyerId") String lawyerId);// 변호사 테이블에서 중복여부 체크

    int countByLawyerId2(@Param("lawyerId") String lawyerId); // 의로인 테이블에서 중복여부 체크

    void insertLawyer(LawyerEntity lawyer);

    LawyerEntity findByEmail(String email);

    LawyerEntity findByClientId(String lawyerId);

    int countByEmail(@Param("email") String email);

    LawyerEntity findByLawyerId(String lawyerId);

    @Select("SELECT lawyer_id FROM lawyer WHERE name = #{fullName} AND email = #{email}")
    String findLawyerId(@Param("fullName") String fullName, @Param("email") String email);

    @Update("UPDATE lawyer SET pw_hash = #{newHashedPassword} WHERE lawyer_id = #{lawyerId}")
    void updatePassword(@Param("lawyerId") String lawyerId, @Param("newHashedPassword") String newHashedPassword);

    void updateLawyerInfo(
            @Param("lawyerId") String lawyerId,
            @Param("officeNumber") String officeNumber,
            @Param("phone") String phone,
            @Param("detailAddress") String detailAddress,
            @Param("zipcode") String zipcode,
            @Param("roadAddress") String roadAddress,
            @Param("landAddress") String landAddress
    );


    List<LawyerDTO> selectLawyerList(Map<String, Object> param);



    List<LawyerDTO> selectAllLawyers();

    void updateStatus(@Param("no") Long no, @Param("status") String status);

    int markAsWithdrawn(@Param("userNo") Long userNo);

}
