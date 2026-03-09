# 🏎️ Indy Schedule

Um aplicativo macOS minimalista para acompanhar o calendário da temporada 2026 da IndyCar Series.

## Funcionalidades

- **Próxima Corrida em Destaque**: Visualize rapidamente qual é a próxima corrida da temporada
- **Calendário Completo**: Lista todas as corridas da temporada 2026
- **Interface Nativa**: Desenvolvido com SwiftUI para uma experiência nativa no macOS
- **Widget Support**: Inclui um widget para acompanhar as corridas direto do seu desktop

## Requisitos

- macOS 13.0 (Ventura) ou superior
- Xcode 14.0 ou superior
- Swift 5.7+

## Instalação (macOS)

O App está atualmente em fase de *Early Access*. A maneira mais fácil de instalar e mantê-lo atualizado é usando o gerenciador de pacotes [Homebrew](https://brew.sh/). Abra o seu terminal e execute os comandos abaixo para adicionar o repositório oficial do projeto e instalar o app:

```bash
# Adiciona o repositório (Tap) ao seu Homebrew
brew tap henriquecdb/homebrew-tap

# Instala o aplicativo
brew install --cask indy-schedule --no-quarantine
```

## Tecnologias

- **SwiftUI**: Framework moderno para construção de interfaces
- **Foundation**: Manipulação de dados e datas
- **WidgetKit**: Extensão de widget para macOS

## Dados das Corridas

As corridas são armazenadas em `Shared/Data/races.json`. Para adicionar ou modificar corridas, edite este arquivo seguindo o formato:

```json
{
  "id": "race-id",
  "name": "Nome da Corrida",
  "date": "2026-MM-DD"
}
```

## Licença

Este projeto é de código aberto e está disponível para uso pessoal e educacional.

## Autor

**Henrique Junqueira**

---

<p align="center">
  Feito para os fãs da IndyCar
</p>
