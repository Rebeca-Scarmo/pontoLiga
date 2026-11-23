// Listagem de atas.

async function carregarAtas() {
  const corpo = document.getElementById('corpo-atas');
  const tabela = document.getElementById('tabela-atas');
  const aviso = document.getElementById('aviso');

  try {
    const atas = await api('/api/atas');
    corpo.replaceChildren();

    if (atas.length === 0) {
      tabela.hidden = true;
      aviso.hidden = false;
      return;
    }

    for (const ata of atas) {
      const linha = document.createElement('tr');
      linha.append(
        celula(ata.titulo),
        celula(ata.dataFormatada),
        celula(ata.primeiroRegistro),
        celula(ata.ultimoRegistro)
      );

      const colunaAcao = document.createElement('td');
      const link = document.createElement('a');
      link.href = '/pages/ata-detalhes.html?data=' + encodeURIComponent(ata.data);
      link.textContent = 'Abrir ata';
      colunaAcao.append(link);
      linha.append(colunaAcao);

      corpo.append(linha);
    }
    tabela.hidden = false;
    aviso.hidden = true;
  } catch (e) {
    mostrarErro(e.message);
  }
}

document.addEventListener('DOMContentLoaded', carregarAtas);
