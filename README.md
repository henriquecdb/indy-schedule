# 🏎️ Indy Schedule

Um aplicativo macOS minimalista para acompanhar o calendário da temporada 2026 da IndyCar Series.

## ✨ Funcionalidades

- **Próxima Corrida em Destaque**: Visualize rapidamente qual é a próxima corrida da temporada
- **Calendário Completo**: Lista todas as corridas da temporada 2026
- **Interface Nativa**: Desenvolvido com SwiftUI para uma experiência nativa no macOS
- **Widget Support**: Inclui um widget para acompanhar as corridas direto do seu desktop

## 📋 Requisitos

- macOS 13.0 (Ventura) ou superior
- Xcode 14.0 ou superior
- Swift 5.7+

## 🛠️ Tecnologias

- **SwiftUI**: Framework moderno para construção de interfaces
- **Foundation**: Manipulação de dados e datas
- **WidgetKit**: Extensão de widget para macOS

## 📝 Dados das Corridas

As corridas são armazenadas em `Shared/Data/races.json`. Para adicionar ou modificar corridas, edite este arquivo seguindo o formato:

```json
{
  "id": "race-id",
  "name": "Nome da Corrida",
  "date": "2026-MM-DD"
}
```

## 🎨 Características da Interface

- **Design Minimalista**: Interface limpa focada na informação essencial
- **Próxima Corrida em Destaque**: Badge visual destacando a próxima corrida
- **Datas Formatadas**: Apresentação clara e legível das datas
- **Lista Organizada**: Todas as corridas organizadas cronologicamente

## 📄 Licença

Este projeto é de código aberto e está disponível para uso pessoal e educacional.

## 👤 Autor

**Henrique Junqueira**

---

<p align="center">
  Feito com ❤️ para fãs da IndyCar
</p>
