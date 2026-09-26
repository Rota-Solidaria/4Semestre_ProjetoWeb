package com.rotasolidaria.rotasolidaria.models;

import jakarta.persistence.*;
import com.rotasolidaria.rotasolidaria.models.enums.ContentType;

@Entity
@Table(name = "educational_contents")
public class EducationalContent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    private ContentType type;

    @Column(length = 140)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String text;

    @Column(name = "display_order") 
    private Integer displayOrder;

    // Getters e Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public ContentType getType() {
        return type;
    }

    public void setType(ContentType type) {
        this.type = type;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public Integer getDisplayOrder() {
        return displayOrder;
    }

    public void setDisplayOrder(Integer displayOrder) {
        this.displayOrder = displayOrder;
    }

    
}