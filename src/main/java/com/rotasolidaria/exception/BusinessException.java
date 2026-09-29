package com.rotasolidaria.exception;

/**
 * Erro de regra de negócio cuja mensagem pode ser exibida diretamente ao usuário
 * (ex.: "Este e-mail já está cadastrado.").
 */
public class BusinessException extends RuntimeException {

    public BusinessException(String message) {
        super(message);
    }
}
