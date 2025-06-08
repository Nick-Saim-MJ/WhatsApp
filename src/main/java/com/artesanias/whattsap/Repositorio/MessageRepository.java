package com.artesanias.whattsap.Repositorio;


import com.artesanias.whattsap.Model.Message;
import com.artesanias.whattsap.Model.MessageStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findByPhoneNumberOrderByCreatedAtDesc(String phoneNumber);
    List<Message> findByStatusOrderByCreatedAtDesc(MessageStatus status);

    @Query("SELECT m FROM Message m WHERE m.createdAt >= CURRENT_DATE ORDER BY m.createdAt DESC")
    List<Message> findTodayMessages();
}
