# Loop Task

Um projeto pessoal criado para atender a necessidade de execução de tarefas que sempre precisam voltar a ser executadas. Todo o conceito gira em torno de ao concluir uma tarefa, ela volta para o final da lista como uma nova tarefa.

## 📋 Características Principais

### Loop Infinito de Tarefas
- **Completar e Reciclar**: Quando uma tarefa é marcada como concluída, ela é automaticamente recriada e adicionada ao final da lista
- **Rastreamento de Histórico**: Mantenha um registro completo de todas as tarefas concluídas com timestamps
- **Continuidade Garantida**: Nunca perca uma tarefa importante - elas sempre voltam para serem executadas novamente

### Funcionalidades Essenciais
- ✅ Criar, editar e excluir tarefas
- 🔄 Sistema de loop automático para tarefas concluídas
- 🌙 Suporte a tema claro e escuro (automático do sistema)
- 🎯 Reordenação de tarefas por arrastar e soltar
- 📊 Visualização de histórico de tarefas finalizadas
- 🔄 Duplicação rápida de tarefas
- 💾 Persistência local com SQLite

## 🛠️ Tecnologias e Arquitetura

### Framework e Linguagem
- **Flutter 3.8+** - Framework multiplataforma
- **Dart** - Linguagem de programação moderna

### Arquitetura
- **Layered Architecture** - Separação clara entre camadas UI, Logic e Data conforme recomendações oficiais do Flutter
- **Repository Pattern** - Abstração da fonte de dados com single source of truth
- **MVVM (Model-View-ViewModel)** - ViewModels gerenciam estado e Views exibem dados, seguindo separação de responsabilidades
- **Unidirectional Data Flow** - Fluxo unidirecional de dados da camada de dados para UI
- **Dependency Injection** - Usando GetIt para inversão de controle e melhor testabilidade

### Principais Dependências
```yaml
# Gerenciamento de Estado
get_it: ^8.2.0

# Persistência de Dados
sqflite: ^2.3.0
shared_preferences: ^2.2.2

# Navegação
go_router: ^15.0.0

# Utilitários
uuid: ^4.4.0
result_dart: ^2.1.1

# Interface
flutter_slidable: ^3.0.1
google_fonts: ^6.2.0
reorderables: ^0.6.0
```

## 🏗️ Estrutura do Projeto

```
lib/
├── config/              # Configurações da aplicação
│   ├── app_routes.dart  # Definição de rotas
│   ├── dependencies.dart # Injeção de dependências
│   └── go_router.dart   # Configuração do roteador
├── data/                # Camada de dados
│   ├── exceptions/      # Exceções específicas de dados
│   ├── repositories/    # Implementações de repositórios
│   └── services/        # Serviços de dados
├── domain/              # Regras de negócio
│   ├── entities/        # Entidades do domínio
│   ├── enums/          # Enumerações
│   └── repositories/    # Contratos de repositório
├── ui/                  # Interface do usuário
│   └── task/           # Telas relacionadas a tarefas
└── utils/              # Utilitários
    ├── constants/      # Constantes da aplicação
    ├── exceptions/     # Exceções base
    └── helpers/        # Funções auxiliares
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.8 ou superior
- Dart SDK
- Android Studio ou VS Code com extensões Flutter/Dart

### Instalação
1. Clone o repositório:
```bash
git clone https://github.com/wevertonj/loop_task.git
cd loop_task
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
# Para desenvolvimento
flutter run

# Para release
flutter run --release
```

### Plataformas Suportadas
- ✅ Android
- 🔲 iOS (configuração necessária)

## 📱 Como Usar

### Gestão Básica de Tarefas
1. **Adicionar Tarefa**: Toque no botão "+" e digite o título da tarefa
2. **Editar Tarefa**: Use o menu de opções (⋮) e selecione "Editar"
3. **Reordenar**: Arraste as tarefas pela alça de reordenação (⋮⋮)
4. **Duplicar**: Use o menu de opções para criar uma cópia rápida

### Sistema de Loop
1. **Completar Tarefa**: Toque no círculo ao lado da tarefa ou na própria tarefa
2. **Loop Automático**: A tarefa será marcada como concluída e uma nova cópia será criada automaticamente
3. **Histórico**: Acesse "Tarefas Finalizadas" para ver o histórico completo

### Funcionalidades Avançadas
- **Animações**: Interface com animações suaves para melhor experiência
- **Feedback Visual**: Confirmações visuais para todas as ações
- **Persistência**: Todos os dados são salvos automaticamente

## 🧪 Testes

Execute os testes do projeto:

```bash
# Testes unitários
flutter test

# Testes de integração
flutter test integration_test/
```

## 📄 Licença

Este projeto está licenciado sob a Licença BSD de 3 Cláusulas - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Weverton J. da Silva** - [GitHub](https://github.com/wevertonj)

## 🔗 Links Úteis

- [Documentação do Flutter](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)

