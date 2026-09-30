package com.rotasolidaria.util;

import com.rotasolidaria.models.Location;
import org.springframework.web.util.UriUtils;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/** Links para abrir um local no app de navegação do doador. */
public final class Navegacao {

    private static final String WAZE = "https://waze.com/ul";

    private Navegacao() {
    }

    /**
     * Link do Waze que já inicia a rota até o local: usa as coordenadas quando existem e cai para o
     * endereço por texto quando não. Nulo se o local não tem coordenadas nem nome ou endereço.
     */
    public static String waze(Location local) {
        if (local == null) {
            return null;
        }
        if (local.hasCoordinates()) {
            // toPlainString: a vírgula decimal do pt-BR ou a notação científica quebrariam o link
            return WAZE + "?ll=" + local.getLatitude().toPlainString() + "," + local.getLongitude().toPlainString()
                    + "&navigate=yes";
        }
        String endereco = endereco(local);
        if (endereco.isEmpty()) {
            return null;
        }
        return WAZE + "?q=" + UriUtils.encodeQueryParam(endereco, StandardCharsets.UTF_8) + "&navigate=yes";
    }

    /** "Rua X, 10, Bairro, Cidade - SP"; sem rua, usa o nome do local no lugar dela. */
    static String endereco(Location local) {
        List<String> partes = new ArrayList<>();
        boolean temRua = preenchido(local.getStreet());
        if (temRua) {
            partes.add(preenchido(local.getNumber()) ? local.getStreet().trim() + ", " + local.getNumber().trim()
                    : local.getStreet().trim());
        } else if (preenchido(local.getName())) {
            partes.add(local.getName().trim());
        }
        if (preenchido(local.getNeighborhood())) {
            partes.add(local.getNeighborhood().trim());
        }
        if (preenchido(local.getCity())) {
            partes.add(preenchido(local.getState()) ? local.getCity().trim() + " - " + local.getState().trim()
                    : local.getCity().trim());
        }
        // Só a cidade não leva a lugar nenhum: sem rua nem nome, não há o que navegar
        return temRua || preenchido(local.getName()) ? String.join(", ", partes) : "";
    }

    private static boolean preenchido(String s) {
        return s != null && !s.isBlank();
    }
}
