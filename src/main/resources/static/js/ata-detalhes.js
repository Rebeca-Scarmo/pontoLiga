// Detalhes de uma ata e impressão (window.print).

function criarLinhaDoPeriodo(periodo) {
  const celulas = [];

  if (periodo.entrada) {
    celulas.push(celula(periodo.entrada));
  } else {
    celulas.push(celula('Não registrada', 'sem-dado'));
  }

  if (periodo.saida) {
    celulas.push(celula(periodo.saida));
  } else if (periodo.saidaPendente) {
    const td = document.createElement('td');
    const selo = document.createElement('span');
    selo.className = 'selo-pendente';
    selo.textContent = 'Saída pendente';
    td.append(selo);
    celulas.push(td);
  } else {
    celulas.push(celula('-', 'sem-dado'));
  }

  celulas.push(periodo.cargaHoraria ? celula(periodo.cargaHoraria) : celula('-', 'sem-dado'));
  return celulas;
}

async function carregarAta() {
  const data = new URLSearchParams(window.location.search).get('data');
  if (!data || !/^\d{4}-\d{2}-\d{2}$/.test(data)) {
    mostrarErro('Data da ata inválida. Volte à listagem e escolha uma ata.');
    return;
  }

  try {
    const ata = await api('/api/atas/' + data);

    document.title = ata.titulo + ' - PontoLiga';
    document.getElementById('ata-titulo').textContent = ata.titulo;
    document.getElementById('ata-data').textContent = ata.dataFormatada;
    document.getElementById('ata-primeiro').textContent = ata.primeiroRegistro;
    document.getElementById('ata-ultimo').textContent = ata.ultimoRegistro;

    const corpo = document.getElementById('corpo-ata');
    corpo.replaceChildren();

    for (const participante of ata.participantes) {
      participante.periodos.forEach((periodo, indice) => {
        const linha = document.createElement('tr');

        // Nome e matrícula aparecem uma vez por membro, ocupando todas as linhas dos seus períodos
        if (indice === 0) {
          const nome = celula(participante.nomeCompleto);
          const matricula = celula(participante.matricula);
          nome.rowSpan = participante.periodos.length;
          matricula.rowSpan = participante.periodos.length;
          linha.append(nome, matricula);
        }

        linha.append(...criarLinhaDoPeriodo(periodo));
        corpo.append(linha);
      });
    }

    document.getElementById('ata').hidden = false;
  } catch (e) {
    mostrarErro(e.message);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('btn-imprimir').addEventListener('click', () => window.print());
  carregarAta();
});
