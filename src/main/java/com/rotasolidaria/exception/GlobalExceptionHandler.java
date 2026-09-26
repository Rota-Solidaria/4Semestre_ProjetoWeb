package com.rotasolidaria.exception;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.NoHandlerFoundException;
import org.springframework.http.HttpStatus;
import org.springframework.ui.Model;

@ControllerAdvice 
public class GlobalExceptionHandler {

     // --- TRATAMENTO PARA ERRO 400 (Bad Request) ---
    @ExceptionHandler({IllegalArgumentException.class, NullPointerException.class})
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public String handleBadRequest(Exception ex, Model model) {
        model.addAttribute("errorMessage", "Requisição inválida: " + ex.getMessage());
        return "errors/400"; // -> templates/errors/400.ftlh
    }

    // --- TRATAMENTO PARA ERRO 404 (Not Found) ---
    @ExceptionHandler(NoHandlerFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public String handleNotFound(NoHandlerFoundException ex, Model model) {
        model.addAttribute("errorMessage", "A página solicitada não foi encontrada.");
        return "errors/404"; // -> templates/errors/404.ftlh
    }

    // --- TRATAMENTO PARA ERRO 500 (Internal Server Error) ---
    @ExceptionHandler(Exception.class) // Captura qualquer outra exceção não tratada
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public String handleInternalServerError(Exception ex, Model model) {
        model.addAttribute("errorMessage", "Ocorreu um erro interno no servidor.");
        return "errors/500"; // -> templates/errors/500.ftlh
    }
}
