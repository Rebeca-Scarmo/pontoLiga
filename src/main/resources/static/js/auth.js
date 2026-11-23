// Login, logout e identificação do usuário logado.

async function tratarLogin(evento) {
  evento.preventDefault();

  const usuario = document.getElementById('usuario').value.trim();
  const senha = document.getElementById('senha').value;
  const erro = document.getElementById('erro-login');
  const botao = document.getElementById('btn-entrar');

  erro.hidden = true;
  if (usuario === '' || senha === '') {
    erro.textContent = 'Informe o usuário e a senha.';
    erro.hidden = false;
    return;
  }

  botao.disabled = true;
  try {
    // O login do Spring Security espera um formulário (username e password).
    const resposta = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'X-XSRF-TOKEN': lerCookie('XSRF-TOKEN') || '' },
      credentials: 'same-origin',
      body: new URLSearchParams({ username: usuario, password: senha }),
    });

    if (resposta.ok) {
      window.location.href = '/pages/atas.html';
      return;
    }
    if (resposta.status === 401) {
      erro.textContent = 'Usuário ou senha inválidos.';
    } else if (resposta.status === 403) {
      erro.textContent = 'A página expirou. Recarregue-a e tente novamente.';
    } else {
      erro.textContent = 'Não foi possível entrar (código ' + resposta.status + ').';
    }
  } catch (e) {
    erro.textContent = 'Não foi possível conectar ao servidor.';
  }
  erro.hidden = false;
  botao.disabled = false;
}

async function sair() {
  try {
    await fetch('/api/auth/logout', {
      method: 'POST',
      headers: { 'X-XSRF-TOKEN': lerCookie('XSRF-TOKEN') || '' },
      credentials: 'same-origin',
    });
  } finally {
    window.location.href = '/pages/login.html';
  }
}

async function mostrarUsuarioLogado() {
  try {
    const usuario = await api('/api/auth/me');
    document.getElementById('usuario-logado').textContent = usuario.username;
  } catch (e) {
    // sem sessão: o api() já redireciona para o login
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const formLogin = document.getElementById('form-login');
  if (formLogin) {
    formLogin.addEventListener('submit', tratarLogin);
  }

  const botaoSair = document.getElementById('btn-sair');
  if (botaoSair) {
    botaoSair.addEventListener('click', sair);
    mostrarUsuarioLogado();
  }
});
