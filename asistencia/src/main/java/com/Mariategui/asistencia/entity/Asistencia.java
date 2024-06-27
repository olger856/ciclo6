package com.Mariategui.asistencia.entity;

import jakarta.persistence.*;
import jakarta.persistence.ManyToOne;
import java.time.LocalDateTime;
import com.Mariategui.asistencia.dto.AuthUser;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import lombok.Data;

@Entity
@Data
public class Asistencia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private Integer userId;
    @Transient
    private AuthUser authUser;
    private Integer asistencia = 1;
    /* 
    ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "evento_id")
    @JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
    private Evento evento;
*/
    private LocalDateTime created_at = LocalDateTime.now();
    private LocalDateTime updated_at = LocalDateTime.now();

    @PreUpdate
    private void preUpdate() {
        updated_at = LocalDateTime.now();
    }
}
