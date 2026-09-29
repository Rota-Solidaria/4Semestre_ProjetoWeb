package com.rotasolidaria.controllers;

import java.io.Serializable;

/**
 * Aviso temporário exibido no rodapé da tela (templates/includes/toast.ftlh).
 *
 * Na mesma requisição: model.addAttribute("toast", Toast.error(...)).
 * Depois de um redirect: redirectAttributes.addFlashAttribute("toast", Toast.success(...).withAction(...)).
 */
public class Toast implements Serializable {

    private final String type;
    private final String title;
    private final String message;
    private String icon;
    private String actionLabel;
    private String actionUrl;

    private Toast(String type, String icon, String title, String message) {
        this.type = type;
        this.icon = icon;
        this.title = title;
        this.message = message;
    }

    public static Toast success(String title, String message) {
        return new Toast("success", "check", title, message);
    }

    public static Toast info(String title, String message) {
        return new Toast("info", "info_i", title, message);
    }

    public static Toast warning(String title, String message) {
        return new Toast("warning", "warning", title, message);
    }

    public static Toast error(String title, String message) {
        return new Toast("error", "priority_high", title, message);
    }

    /** Troca o ícone padrão do tipo (nome de um Material Symbol, ex.: "mail"). */
    public Toast withIcon(String icon) {
        this.icon = icon;
        return this;
    }

    /** Adiciona um link de ação ao lado do texto (ex.: "Redefinir senha"). */
    public Toast withAction(String label, String url) {
        this.actionLabel = label;
        this.actionUrl = url;
        return this;
    }

    // Tempo até sumir sozinho: erros e avisos ficam mais tempo na tela
    public int getDuration() {
        return switch (type) {
            case "error" -> 10000;
            case "warning" -> 8000;
            default -> 6000;
        };
    }

    public String getType() {
        return type;
    }

    public String getIcon() {
        return icon;
    }

    public String getTitle() {
        return title;
    }

    public String getMessage() {
        return message;
    }

    public String getActionLabel() {
        return actionLabel;
    }

    public String getActionUrl() {
        return actionUrl;
    }
}
