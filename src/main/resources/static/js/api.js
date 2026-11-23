// Funções comuns a todas as páginas: chamadas HTTP, cookies e mensagens de erro.

class ErroApi extends Error {
  constructor(mensagem, status, dados) {
    super(mensagem);
    this.status = status;
    this.dados = dados;
  }
}

function lerCookie(nome) {
  const par = document.cookie.split('; ').find((c) => c.startsWith(nome + '='));
  return par ? decodeURIComponent(par.substring(nome.length + 1)) : null;
}

function mensagemDeErro(status, dados) {
  if (status === 403) {
    return 'Ação não autorizada. Recarregue a página e tente novamente.';
  }
  if (dados && dados.campos && Object.keys(dados.campos).length > 0) {
    return Object.values(dados.campos).join(' ');
  }
  if (dados && dados.mensagem) {
    return dados.mensagem;
  }
  if (dados && dados.detail) {
    return dados.detail;
  }
  return 'Não foi possível concluir a operação (código ' + status + ').';
}

// Chamada à API do painel. "corpo" é um objeto, enviado como JSON.
// Em caso de sessão expirada (401), volta para o login.
async function api(url, opcoes = {}) {
  const metodo = (opcoes.method || 'GET').toUpperCase();
  const cabecalhos = { Accept: 'application/json' };

  if (opcoes.corpo !== undefined) {
    cabecalhos['Content-Type'] = 'application/json';
  }
  if (metodo !== 'GET') {
    const token = lerCookie('XSRF-TOKEN');
    if (token) {
      cabecalhos['X-XSRF-TOKEN'] = token;
    }
  }

  let resposta;
  try {
    resposta = await fetch(url, {
      method: metodo,
      headers: cabecalhos,
      credentials: 'same-origin',
      body: opcoes.corpo !== undefined ? JSON.stringify(opcoes.corpo) : undefined,
    });
  } catch (e) {
    throw new ErroApi('Não foi possível conectar ao servidor.', 0, null);
  }

  if (resposta.status === 401) {
    window.location.href = '/pages/login.html';
    throw new ErroApi('Sessão expirada. Faça login novamente.', 401, null);
  }

  const texto = await resposta.text();
  let dados = null;
  if (texto) {
    try {
      dados = JSON.parse(texto);
    } catch (e) {
      dados = null;
    }
  }

  if (!resposta.ok) {
    throw new ErroApi(mensagemDeErro(resposta.status, dados), resposta.status, dados);
  }
  return dados;
}

// Cria uma célula de tabela com texto puro (evita injetar HTML vindo do banco).
function celula(texto, classe) {
  const td = document.createElement('td');
  td.textContent = texto;
  if (classe) {
    td.className = classe;
  }
  return td;
}

function mostrarErro(mensagem) {
  const caixa = document.getElementById('erro');
  if (caixa) {
    caixa.textContent = mensagem;
    caixa.hidden = false;
  }
}
