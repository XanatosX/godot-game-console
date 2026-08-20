# Contributing to Godot Console Plugin

Thank you for considering contributing to the **Godot Console Plugin**! Your contributions help improve the project for everyone. Below are guidelines to ensure a smooth and effective collaboration.

## Getting Started

### Prerequisites
- **Godot Engine 4.7+**: Ensure you have the latest version of Godot installed.
- **Git**: Required for cloning and contributing to the repository.
- **Basic Knowledge**: Familiarity with **GdScript**, or **Godot's plugin system** is helpful.

### Setting Up the Project
1. **Fork the Repository**: Create a fork of the project on GitHub.
2. **Clone Your Fork**:
   ```bash
   git clone https://github.com/your-username/godot-console-plugin.git
   cd godot-console-plugin
   ```
3. **Open the Project**: Follow the project's `README.md` for specific setup instructions.

## Contribution Guidelines

### Code Style

- Follow **Godot's official style guide** for GdScript and C#.
- Keep lines under **72 characters** for readability.
- Use **descriptive variable and function names**.

### Commit Messages

This project uses [Conventional Commits][conventional-commits] to maintain a clear and structured commit history. Follow the format below:

```plaintext
<type>(<scope>): <description>

[optional body]

[optional footer]
```

The scope is optional, with out a scope defined use this format:

```plaintext
<type>: <description>

[optional body]

[optional footer]
```

> :warning: Make sure the title does not exceed **50 characters** in length

#### Commit Types

| Type       | Description                                                                                     |
|------------|-------------------------------------------------------------------------------------------------|
| `feat`     | A new feature                                                                                   |
| `fix`      | A bug fix                                                                                       |
| `docs`     | Documentation-only changes                                                                     |
| `style`    | Changes that do not affect the meaning of the code (e.g., formatting, missing semicolons)     |
| `refactor` | A code change that neither fixes a bug nor adds a feature                                     |
| `perf`     | A code change that improves performance                                                        |
| `test`     | Adding missing tests                                                                           |
| `chore`    | Changes to the build process or auxiliary tools and libraries such as documentation generation|

#### Examples

- `feat(console): add command history support`
- `fix(parser): handle edge case for empty input`
- `docs(readme): update installation instructions`
- `refactor(utils): simplify string parsing logic`

#### Scope

- The scope should specify the **part of the codebase** affected by the commit (e.g., `console`, `parser`, `ui`).
- If the change affects multiple areas, use `*` or no scope (e.g., `feat(*): add global error handling` or `feat: add global error handling`).

#### Body
- Use the body to explain **what** was changed and **why** it was changed.
- Wrap the body at **72 characters** for readability.

#### Footer
- Use the footer to reference **issues** or **pull requests** (e.g., `Closes #123`).

## How to Contribute

### Reporting Issues

- **Check Existing Issues**: Ensure the [issue][issues] hasn't already been reported.
- **Provide Details**: Include steps to reproduce, expected vs. actual behavior, and screenshots if applicable.
- **Use the Issue Template**: Fill out the provided template for bug reports or feature requests.

### Submitting Changes

1. **Create a Branch**: Use a descriptive name (e.g., `feat/add-command-history`).
   ```bash
   git checkout -b feat/add-command-history
   ```
2. **Make Your Changes**: Ensure your code follows the project's style and conventions.
3. **Test Your Changes**: Verify that your changes work as expected and do not break existing functionality.
4. **Commit Your Changes**: Use **Conventional Commits** for your commit messages.
   ```bash
   git commit -m "feat(console): add command history support"
   ```
5. **Push to Your Fork**:
   ```bash
   git push origin feat/add-command-history
   ```
6. **Open a Pull Request (PR)**:
   - Target the `main` branch of the original repository.
   - Provide a **clear title and description** for your PR.
   - Reference any related issues (e.g., `Closes #123`).

## Pull Request Review Process

1. **Automated Checks**: Your PR will be checked for **Conventional Commits** compliance and code style.
2. **Manual Review**: A maintainer will review your PR for:
   - Code quality and adherence to guidelines.
   - Functionality and edge cases.
   - Documentation updates (if applicable).
3. **Feedback**: Address any requested changes or questions promptly.
4. **Merge**: Once approved, your PR will be merged into the `main` branch.

## License

By contributing to this project, you agree that your contributions will be licensed under the **[MIT License][license]**.

## Questions or Need Help?

- Open a **discussion** on GitHub for general questions.
- Contact the maintainers directly for urgent matters.

Thank you for your contributions! 🎉

> :information_source: This file was partly generated by AI but reviewed and adapted by a human.

[conventional-commits]: https://www.conventionalcommits.org/en/v1.0.0/
[license]: LICENSE
[issues]: https://github.com/XanatosX/godot-game-console/issues