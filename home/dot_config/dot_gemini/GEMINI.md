# Global Gemini Instructions

These instructions apply across all projects and reflect the user's core
engineering philosophy.

## Architectural Principles

- **Hexagonal Architecture (Ports & Adapters):** Maintain a clear separation
  between the application's domain logic and external concerns (databases, UIs,
  APIs).
- **Domain-Driven Design (DDD):** Use a rich domain model to encapsulate
  business logic. Respect boundaries between Bounded Contexts.
- **Functional Core, Imperative Shell:** Strive for pure, side-effect-free logic
  at the core of the application, with side effects and state management handled
  at the edges.
- **Event-Driven Architecture:** Prefer asynchronous communication and
  event-driven patterns where appropriate to decouple system components.

## Engineering Standards

- **Type Safety:** Prioritize strict type safety. Avoid casts and 'any' types.
- **Testing:** Comprehensive automated testing is mandatory. Prefer a mix of
  unit, integration, and end-to-end tests to verify both logic and behavior.
- **Clean Abstractions:** Favor explicit composition and delegation over complex
  inheritance.
- **Commit Hygiene:** Follow Conventional Commits and provide clear, descriptive
  commit messages focused on "why" rather than "what".

## Tooling & Workflow

- **Automation:** Always utilize project-specific formatters and linters (e.g.,
  Prettier, ESLint, Ruff) before submitting changes.
- **Documentation:** Maintain clear and concise documentation for architectural
  decisions and complex logic.
- **Proactive Opinion:** Provide technical rationale for decisions, especially
  when they impact the core architecture or domain model.
