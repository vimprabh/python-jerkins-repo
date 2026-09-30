import sys

from jenkins_uv_starter.app import greeting, main


def test_greeting_uses_default() -> None:
    assert greeting() == "Hello, world!"
    assert greeting("  ") == "Hello, world!"


def test_greeting_trims_name() -> None:
    assert greeting("  Ada  ") == "Hello, Ada!"


def test_cli_prints_greeting(monkeypatch, capsys) -> None:
    monkeypatch.setattr(sys, "argv", ["hello-jenkins", "--name", "Ada"])
    main()
    assert capsys.readouterr().out == "Hello, Ada!\n"
