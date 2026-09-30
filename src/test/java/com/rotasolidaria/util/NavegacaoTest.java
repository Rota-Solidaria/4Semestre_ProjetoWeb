package com.rotasolidaria.util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

import java.math.BigDecimal;

import org.junit.jupiter.api.Test;

import com.rotasolidaria.models.Location;

class NavegacaoTest {

    @Test
    void comCoordenadasUsaLatitudeELongitude() {
        Location l = new Location();
        l.setName("Hemocentro");
        l.setLatitude(new BigDecimal("-23.5573000"));
        l.setLongitude(new BigDecimal("-46.6697000"));
        assertEquals("https://waze.com/ul?ll=-23.5573000,-46.6697000&navigate=yes", Navegacao.waze(l));
    }

    @Test
    void semCoordenadasUsaOEnderecoCodificado() {
        Location l = new Location();
        l.setName("Colsan");
        l.setStreet("Rua Dr. Álvaro Soares");
        l.setNumber("10");
        l.setNeighborhood("Centro");
        l.setCity("Sorocaba");
        l.setState("SP");
        assertEquals("https://waze.com/ul?q=Rua%20Dr.%20%C3%81lvaro%20Soares,%2010,%20Centro,%20Sorocaba%20-%20SP&navigate=yes",
                Navegacao.waze(l));
    }

    @Test
    void semRuaUsaONomeDoLocal() {
        Location l = new Location();
        l.setName("Hemocentro de Sorocaba");
        l.setCity("Sorocaba");
        assertEquals("https://waze.com/ul?q=Hemocentro%20de%20Sorocaba,%20Sorocaba&navigate=yes", Navegacao.waze(l));
    }

    @Test
    void semCoordenadasNemEnderecoNaoGeraLink() {
        Location soCidade = new Location();
        soCidade.setCity("Sorocaba");
        assertNull(Navegacao.waze(soCidade));
        assertNull(Navegacao.waze(new Location()));
        assertNull(Navegacao.waze(null));
    }
}
