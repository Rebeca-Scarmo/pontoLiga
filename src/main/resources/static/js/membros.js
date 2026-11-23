// Cadastro e consulta de membros.

let membroEditandoId = null;

const modal = document.getElementById('modal-membro');
const formulario = document.getElementById('form-membro');
const erroFormulario = document.getElementById('erro-form');

function abrirModal(membro) {
  membroEditandoId = membro ? membro.id : null;
  document.getElementById('modal-titulo').textContent = membro ? 'Editar membro' : 'Cadastrar membro';
  formulario.elements['nomeCompleto'].value = membro ? membro.nomeCompleto : '';
  formulario.elements['matricula'].value = membro ? membro.matricula : '';
  formulario.elements['uidTag'].value = membro ? membro.uidTag : '';
  erroFormulario.hidden = true;
  modal.showModal();
  formulario.elements['nomeCompleto'].focus();
}

async function carregarMembros() {
  const corpo = document.getElementById('corpo-membros');
  const tabela = document.getElementById('tabela-membros');
  const aviso = document.getElementById('aviso');

  try {
    const membros = await api('/api/membros');
    corpo.replaceChildren();

    if (membros.length === 0) {
      tabela.hidden = true;
      aviso.hidden = false;
      return;
    }

    for (const membro of membros) {
      const linha = document.createElement('tr');
      linha.append(celula(membro.nomeCompleto), celula(membro.matricula), celula(membro.uidTag, 'codigo'));

      const colunaAcoes = document.createElement('td');
      const botaoEditar = document.createElement('button');
      botaoEditar.type = 'button';
      botaoEditar.className = 'btn btn-claro btn-pequeno';
      botaoEditar.textContent = 'Editar';
      botaoEditar.addEventListener('click', () => abrirModal(membro));
      colunaAcoes.append(botaoEditar);
      linha.append(colunaAcoes);

      corpo.append(linha);
    }
    tabela.hidden = false;
    aviso.hidden = true;
  } catch (e) {
    mostrarErro(e.message);
  }
}

async function salvarMembro(evento) {
  evento.preventDefault();
  erroFormulario.hidden = true;

  const dados = {
    nomeCompleto: formulario.elements['nomeCompleto'].value.trim(),
    matricula: formulario.elements['matricula'].value.trim(),
    uidTag: formulario.elements['uidTag'].value.trim().toUpperCase(),
  };

  if (dados.nomeCompleto === '' || dados.matricula === '' || dados.uidTag === '') {
    erroFormulario.textContent = 'Preencha o nome completo, a matrícula e o UID da tag RFID.';
    erroFormulario.hidden = false;
    return;
  }

  try {
    if (membroEditandoId === null) {
      await api('/api/membros', { method: 'POST', corpo: dados });
    } else {
      await api('/api/membros/' + membroEditandoId, { method: 'PUT', corpo: dados });
    }
    modal.close();
    await carregarMembros();
  } catch (e) {
    erroFormulario.textContent = e.message;
    erroFormulario.hidden = false;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  document.getElementById('btn-novo').addEventListener('click', () => abrirModal(null));
  document.getElementById('btn-cancelar').addEventListener('click', () => modal.close());
  formulario.addEventListener('submit', salvarMembro);
  carregarMembros();
});
