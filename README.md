# 🛠️ TechSupport CLI

Ferramenta de suporte técnico e manutenção de computadores Windows, desenvolvida em **PowerShell**.

## 📌 Sobre o projeto

O TechSupport CLI foi desenvolvido para facilitar tarefas comuns de suporte técnico, diagnóstico e manutenção de computadores por meio de uma interface de linha de comando (CLI).

## ⚙️ Funcionalidades

- 💻 Diagnóstico do computador (processador, memória RAM e armazenamento)
- 🔧 Reparação do Windows com DISM e SFC
- 🧹 Limpeza de arquivos temporários
- 🔄 Acesso ao Windows Update para atualização de drivers
- 💾 Otimização de HDD e SSD
- 🔍 Verificação de integridade do disco com CHKDSK

## ▶️ Como executar

1. Baixe ou clone o repositório.
2. Abra o PowerShell no diretório do projeto.
3. Execute o script:

```powershell
.\suporte.ps1
```

Algumas funcionalidades exigem privilégios de administrador.

## 🔒 Segurança

O programa solicita confirmação antes das operações de limpeza. Reparos e verificações administrativas devem ser realizados com as permissões adequadas.

Recomenda-se realizar backup antes de intervenções em computadores de produção.

## 📈 Próximas melhorias

- Relatórios técnicos em HTML
- Monitoramento de CPU e memória RAM
- Histórico de manutenção e logs
- Interface com mais opções de diagnóstico
- Distribuição por executável Windows

## 👨‍💻 Objetivo

Projeto desenvolvido para praticar automação com PowerShell e aplicar conhecimentos de suporte técnico e infraestrutura de TI.