# Ambientação 53: Verificador Automatizado (22 Itens)
### SENAI São Paulo Skills · Ciclo 2026-2028
### Ocupação #53 — Computação em Nuvem

> **Autor:** [Prof. Esp. Leandro Gaudio Rosa](https://www.linkedin.com/in/leandro-gr/) ([@Leandromeda no GitHub](https://github.com/Leandromeda/))  
> **Licença & Proteção:** Direitos Reservados. Proteção ativa contra plágio, web scraping e clonagem não autorizada por IA.

---

## 📋 Visão Geral

Este pacote foi desenvolvido para automatizar integralmente a auditoria estação por estação para a competição **São Paulo Skills (Ocupação #53 - Computação em Nuvem)**, com base no checklist oficial de instalação consolidado para o ciclo 2026-2028.

### 🔄 Novo Fluxo de Trabalho (Auditoria Primeiro, Identificação Depois)
1. **Auditoria Imediata:** Ao iniciar, o script analisa imediatamente os 22 itens do sistema e exibe na tela o status de cada um com telemetria técnica.
2. **Ciclo de Correção e Reavaliação:** O avaliador visualiza o resumo das conformidades e não conformidades:
   - Se houver pendências corrigíveis (ex: instalar um software faltante ou conectar monitor), o avaliador pode aplicar a correção e selecionar a opção **[2] Rodar Auditoria Novamente**.
   - Se as pendências forem conhecidas e definitivas, ou se a máquina estiver 100% pronta, seleciona **[1] Preencher dados e Gerar Relatórios**.
3. **Identificação Dinâmica (Sem Nomes Padrão):** O nome do Avaliador Responsável é obrigatório e digitado na hora, e o Avaliador 2 é opcional (sem avaliadores pré-definidos).

---

## 🛠️ Itens Auditados (22 Itens Oficiais)

| ID | Item Exigido | Método de Verificação Técnica |
|:--:|:-------------|:------------------------------|
| **01** | Computador Intel Core i5 13ª Geração, 16 GB RAM, SSD 1TB, Windows 11, duas saídas de vídeo. | WMI/CIM Win32_Processor (Intel i5 13ª gen), Win32_ComputerSystem (RAM >= 16GB), Win32_DiskDrive (SSD >= 1TB), Win32_OperatingSystem (Win 11 Build >= 22000) e adaptadores/telas ativas. |
| **02** | Google Chrome. | Detecção via App Paths, `%ProgramFiles%`, LocalAppData e registro Uninstall. |
| **03** | AWS CLI. | Execução de `aws --version` e busca em `%ProgramFiles%\Amazon\AWSCLIV2\aws.exe`. |
| **04** | Monitor LED 23” e Monitor de até 15.5” (Podendo ser monitor integrado). | Contagem de telas ativas via `System.Windows.Forms.Screen`, resoluções e cálculo de polegadas físicas via EDID/WMI. |
| **05** | Acesso à internet. | Teste de conectividade e handshake TCP/HTTPS em múltiplos destinos confiáveis (AWS, Google, Cloudflare). |
| **06** | Mozilla Firefox. | Detecção via App Paths, `%ProgramFiles%` e registro Uninstall. |
| **07** | Putty. | Detecção de `putty.exe` no PATH do sistema, `%ProgramFiles%\PuTTY` e registro. |
| **08** | Visual Code Studio (Plugins apenas os padrões de instalação). | Detecção do executável `code`, auditoria de plugins via `code --list-extensions` e alerta para o avaliador caso haja extensões de terceiros. |
| **09** | Python 3 atualizado. | Execução de `python --version` / `py -3`, validação de versão 3.x (ex: 3.10+) e caminho do executável. |
| **10** | Usuário com perfil de administrador. | Checagem de token de processo elevado (`IsInRole Administrator`) e pertencimento do usuário ao grupo local Administradores (SID `S-1-5-32-544`). |
| **11** | Veyon (para monitoramento). | Detecção de executáveis em `%ProgramFiles%\Veyon`, chave de registro e status do serviço `VeyonService`. |
| **12** | Deep Freeze (Avaliador Líder possui as licenças). | Detecção de processo/binário `DFC.exe` / `FrzState2k.exe`, serviço `DF5Serv`, driver `DeepFrz.sys` e registro Faronics. |
| **13** | Microsoft Edge. | Detecção de `msedge.exe` em `%ProgramFiles(x86)%` e registro Uninstall. |
| **14** | Git. | Execução de `git --version` e localização de `git.exe` no PATH / `%ProgramFiles%\Git`. |
| **15** | 7-Zip ou WinRAR. | Detecção de `7z.exe` ou `WinRAR.exe` no sistema de arquivos e registro. |
| **16** | Decoder de Base62 (Offline ou Online). | Verificação de lib Python `base62`, utilitário offline HTML incluso (`tools/base62_decoder.html`) e conectividade online. |
| **17** | Git-Dumper (Python Lib). | Validação do pacote via `pip show git-dumper` ou comando CLI `git-dumper`. |
| **18** | Ferramenta para Esteganografia (Offline ou Online). | Detecção de ferramentas CLI (`steghide`, `stegsolve`), libs Python (`stegano`, `stepic`), utilitário offline incluso (`tools/stego_tool.html`) e ferramentas web. |
| **19** | EXIF Extractor (Offline ou Online; deve retornar o campo Description). | Detecção de ferramentas com suporte explícito à tag `ImageDescription` / Description (Tag 0x010E), incluindo ExifTool, Python Pillow e utilitário offline local (`tools/exif_inspector.html`). |
| **20** | WSL. | Verificação 100% passiva via Registro (`Lxss`), Serviços do Windows (`LxssManager`) e pacotes AppX modernos (sem disparos do executável `wsl.exe` para prevenir solicitações UAC de elevação ou travamentos). |
| **21** | OBS Studio. | Detecção de `obs64.exe` em `%ProgramFiles%\obs-studio\bin\64bit\` e registro. |
| **22** | Postman. | Detecção de `Postman.exe` em LocalAppData, Program Files e registro. |

---

## 🚀 Como Executar

### Opção 1: Execução Fácil via Batch (.bat)
Dê um duplo clique no arquivo:
```cmd
verificar_checklist.bat
```
*A auditoria dos 22 itens rodará imediatamente. Ao final, escolha se deseja corrigir algo e reauditar, ou informar os dados e gerar o PDF oficial.*

### Opção 2: Exclusão de Relatórios Anteriores (.bat)
Para limpar a pasta e remover todos os relatórios gerados em testes anteriores (`.pdf`, `.json` e `.html`), dê um duplo clique no arquivo:
```cmd
excluir_relatorios.bat
```
*(O script lista todos os relatórios encontrados com seus tamanhos e solicita confirmação antes da remoção, ou pode ser executado com `excluir_relatorios.bat /y` para exclusão direta sem confirmação).*

### Opção 3: Linha de Comando (CMD ou PowerShell)
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\verificar_checklist.ps1
```

#### Modo Direto / CI Automático:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\verificar_checklist.ps1 -Auto -Estacao "06" -Competidor "Alex Nogueira Gonçalves / 1.38" -Avaliador1 "Carlos Silva" -Avaliador2 "Mariana Souza"
```

#### Parâmetros Suportados:
- `-Estacao <string>`: Identificador da estação / computador (ex: `"06"`).
- `-Competidor <string>`: Nome do competidor e código da escola (ex: `"Alex Nogueira Gonçalves / 1.38"`).
- `-Avaliador1 <string>`: Nome do Avaliador Responsável (obrigatório, sem avaliador padrão).
- `-Avaliador2 <string>`: Nome do Segundo Avaliador (opcional, sem avaliador padrão).
- `-Avaliador <string>`: Nome consolidado do(s) avaliador(es) para retrocompatibilidade.
- `-Auto`: Executa de forma direta e não interativa gerando relatórios com os parâmetros informados.
- `-GerarPdf`: Gera diretamente o relatório oficial em PDF via motor Chromium headless (padrão: `$true`).
- `-GerarJson`: Gera arquivo de telemetria estruturado em JSON (padrão: `$true`).
- `-ManterHtml`: Mantém o arquivo intermediário `.html` na pasta (padrão: `$false`, deixando apenas PDF e JSON).
- `-AbrirRelatorio`: Abre automaticamente o relatório PDF gerado no visualizador padrão.

---

## 🧰 Ferramentas Offline Inclusas (`tools/`)

Para garantir que a estação atenda aos requisitos **(Offline ou Online)** mesmo em ambientes sem internet ou isolados da rede, o pacote já inclui ferramentas locais 100% funcionais:

1. **`tools/base62_decoder.html`**: Decodificador e codificador Base62 interativo offline (Item 16).
2. **`tools/exif_inspector.html`**: Analisador de metadados EXIF offline com destaque e extração direta da tag `ImageDescription` / `Description` (Tag 0x010E) (Item 19).
3. **`tools/stego_tool.html`**: Visualizador de planos de bits (Bit Planes 0-7) e extrator de texto LSB offline (Item 18).

---

## 📄 Relatórios Gerados

Ao término de cada execução, são criados na pasta raiz:
1. `relatorio_checklist_estacao_[NUM]_[DATA].pdf`: **Relatório oficial em PDF**, perfeitamente renderizado no padrão A4 oficial do SENAI São Paulo Skills, com assinaturas digitais dinâmicas dos avaliadores informados, caixas de marcação estilizadas, tabelas e hashes de integridade.
2. `relatorio_checklist_estacao_[NUM]_[DATA].json`: Exportação completa de telemetria estruturada contendo metadados, status booleano de conformidade, versões detectadas, observações técnicas e hashes de integridade.

---

## 🛡️ Autoria e Proteção

- **Desenvolvido por:** [Prof. Esp. Leandro Gaudio Rosa](https://www.linkedin.com/in/leandro-gr/) ([@Leandromeda no GitHub](https://github.com/Leandromeda/))
- **Ocupação:** #53 — Computação em Nuvem
- **Evento:** SENAI São Paulo Skills · Ciclo 2026-2028
- **Assinatura Digital:** SHA-256 Validated
