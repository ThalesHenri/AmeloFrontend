# 🏰 Amelo App: O Grimório de Gestão Condominial

Bem-vindo ao Amelo App, a solução definitiva para evitar que a administração de um condomínio se torne um círculo do inferno de Dante. Este projeto foi forjado com o suor de desenvolvedores, litros de café e uma quantidade questionável de gambiarras que, por algum milagre, estão em produção.

## 📜 A Stack (Nossos Feitiços)

Não reinventamos a roda (embora tenhamos tentado, por curiosidade técnica):

*   **Backend:** [Django REST Framework](https://www.djangoproject.com/). Nosso mago de backend. Cuida da burocracia, das permissões e garante que o banco de dados não entre em combustão espontânea.
*   **Frontend:** [Flutter](https://flutter.dev/). O artesão visual. Garante que, mesmo que o código seja uma zona, o usuário final veja algo bonito e fluido no Android e iOS.
*   **Comunicação:** JSON. A língua franca que os dois lados falam, contanto que o Django não decida ser difícil.

## 🛠️ O Ritual de Instalação (Setup)

Se você quer rodar isso na sua máquina, prepare-se. Siga o ritual com fé:

### 1. Preparando o Terreno
Certifique-se de ter o Flutter SDK instalado. Rode `flutter doctor` e reze para que não apareçam mais de três avisos vermelhos.

### 2. Conjuração do Repositório
```bash
git clone <url-do-seu-projeto>
cd amelo_app
```
3. A Invocação das Dependências

Não tente rodar o app sem as dependências, ou o compilador irá zombar de você:
Bash

flutter pub get

4. Conexão com o Oráculo (Backend)

Nosso app espera que o backend esteja disponível. Se você tentar conectar e der erro, verifique se o servidor Django está rodando na porta 8080.

    Dica de sobrevivência: Se estiver usando um emulador Android, o localhost é uma ilusão. Use 10.0.2.2.

5. O Lançamento (Run)
Bash

flutter run

Se compilar de primeira, vá comprar um bilhete de loteria. Se não, bem-vindo à vida real de um dev.
🏗️ Estrutura do Reino (Arquitetura)

Respeite as pastas ou o código irá se vingar:

    lib/core/: Onde guardamos as cores e temas. Não altere a paleta de cores se não quiser ser excomungado pelos designers.

    lib/models/: As entidades do nosso mundo. Onde o JSON é tratado.

    lib/services/: Onde a magia da rede acontece. Se der erro de conexão, é aqui aonde pode estar.

    lib/screens/: As interfaces. Onde o Usuário acha que fica o programa.

⚖️ Regras de Conduta para Desenvolvedores

    "Funciona na minha máquina" não é desculpa: Se não rodar no CI/CD, não vale.

    Histórico é sagrado: O módulo de auditoria não perdoa. Cada alteração é registrada. Se fizer bobagem, saberemos.

    Não toque no código legad... digo, no código principal sem autorização: Se você ver um bloco de código estranho e antigo, é provavelmente uma gambiarra que sustenta metade do sistema. Deixe-o em paz.

    "Que seus deploys sejam rápidos, seus bugs triviais e que a sexta-feira seja um dia de paz, não de chamados de suporte."

— T.H. o Cinzento

Abaixo foi tudo gerado pelo flutter

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
