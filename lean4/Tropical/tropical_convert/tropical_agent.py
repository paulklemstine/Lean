#!/usr/bin/env python3
"""
App 2: Tropical CLI Software Engineering Agent

A CLI-based software engineering assistant powered by a tropicalized language
model. Provides an interactive REPL for code generation, editing, explanation,
and file manipulation — similar to Claude Code but running locally on your
tropical model.

Usage:
    python tropical_agent.py ./tropical_Qwen_Qwen2.5-0.5B
    python tropical_agent.py ./my_model --temperature 0.8
    python tropical_agent.py ./my_model --system "You are a Python expert"

Features:
    - Interactive REPL with syntax-highlighted output
    - File reading and writing commands
    - Multi-turn conversation with context
    - Shell command execution
    - Code block extraction and application
    - Streaming token generation
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, List

import torch

from tropicalize.layers import TropicalCausalLM
from tropicalize.converter import build_tropical_model

# Optional rich/prompt-toolkit imports with fallbacks
try:
    from rich.console import Console
    from rich.markdown import Markdown
    from rich.panel import Panel
    from rich.syntax import Syntax
    from rich.text import Text
    HAS_RICH = True
except ImportError:
    HAS_RICH = False

try:
    from prompt_toolkit import prompt as pt_prompt
    from prompt_toolkit.history import FileHistory
    from prompt_toolkit.auto_suggest import AutoSuggestFromHistory
    HAS_PROMPT_TOOLKIT = True
except ImportError:
    HAS_PROMPT_TOOLKIT = False


# ═══════════════════════════════════════════════════════════
#  Configuration
# ═══════════════════════════════════════════════════════════

@dataclass
class AgentConfig:
    model_path: str = ""
    temperature: float = 0.7
    top_p: float = 0.9
    top_k: int = 50
    max_tokens: int = 2048
    system_prompt: str = (
        "You are a helpful software engineering assistant. "
        "You write clean, well-documented code. "
        "You explain your reasoning step by step. "
        "When asked to modify files, you show the exact changes needed."
    )
    device: str = "auto"

    def effective_device(self) -> torch.device:
        if self.device == "auto":
            if torch.cuda.is_available():
                return torch.device("cuda")
            elif hasattr(torch.backends, "mps") and torch.backends.mps.is_available():
                return torch.device("mps")
            return torch.device("cpu")
        return torch.device(self.device)


# ═══════════════════════════════════════════════════════════
#  Model Loading
# ═══════════════════════════════════════════════════════════

def load_tropical_model(model_path: str, device: torch.device):
    """Load a saved tropical model and tokenizer."""
    model_dir = Path(model_path)

    if not model_dir.exists():
        print(f"Error: Model directory not found: {model_dir}")
        sys.exit(1)

    # Load architecture
    arch_file = model_dir / "arch_params.json"
    if not arch_file.exists():
        print(f"Error: arch_params.json not found in {model_dir}")
        sys.exit(1)

    arch_params = json.loads(arch_file.read_text())

    # Load metadata for temperature info
    meta_file = model_dir / "metadata.json"
    metadata = json.loads(meta_file.read_text()) if meta_file.exists() else {}

    # Build model
    final_temp = metadata.get("final_temperature", 0.01)
    model = build_tropical_model(arch_params, initial_temperature=final_temp)

    # Load weights
    weights_file = model_dir / "tropical_model.pt"
    if not weights_file.exists():
        print(f"Error: tropical_model.pt not found in {model_dir}")
        sys.exit(1)

    state_dict = torch.load(weights_file, map_location="cpu", weights_only=True)
    model.load_state_dict(state_dict)
    model = model.to(device).eval()

    # Load tokenizer
    from transformers import AutoTokenizer
    tokenizer = AutoTokenizer.from_pretrained(str(model_dir), trust_remote_code=True)

    return model, tokenizer, arch_params, metadata


# ═══════════════════════════════════════════════════════════
#  Conversation Manager
# ═══════════════════════════════════════════════════════════

@dataclass
class Message:
    role: str  # "system", "user", "assistant"
    content: str


class Conversation:
    """Manages multi-turn conversation state."""

    def __init__(self, system_prompt: str, tokenizer, max_context: int = 4096):
        self.messages: List[Message] = [Message("system", system_prompt)]
        self.tokenizer = tokenizer
        self.max_context = max_context

    def add_user(self, content: str):
        self.messages.append(Message("user", content))

    def add_assistant(self, content: str):
        self.messages.append(Message("assistant", content))

    def format_prompt(self) -> str:
        """Format conversation history into a prompt string."""
        parts = []
        for msg in self.messages:
            if msg.role == "system":
                parts.append(f"<|system|>\n{msg.content}\n")
            elif msg.role == "user":
                parts.append(f"<|user|>\n{msg.content}\n")
            elif msg.role == "assistant":
                parts.append(f"<|assistant|>\n{msg.content}\n")

        # Add the assistant prefix for generation
        parts.append("<|assistant|>\n")
        return "".join(parts)

    def to_token_ids(self, device: torch.device) -> torch.LongTensor:
        """Tokenize the full conversation, truncating old messages if needed."""
        prompt = self.format_prompt()
        tokens = self.tokenizer.encode(prompt, add_special_tokens=False)

        # Truncate from the front if too long (keep system prompt + recent)
        if len(tokens) > self.max_context:
            tokens = tokens[-self.max_context:]

        return torch.tensor([tokens], dtype=torch.long, device=device)

    def clear(self):
        """Clear conversation history (keep system prompt)."""
        self.messages = [self.messages[0]]


# ═══════════════════════════════════════════════════════════
#  Agent Commands
# ═══════════════════════════════════════════════════════════

COMMANDS = {}


def command(name: str, help_text: str):
    """Decorator to register a slash command."""
    def decorator(func):
        COMMANDS[name] = {"func": func, "help": help_text}
        return func
    return decorator


@command("help", "Show available commands")
def cmd_help(agent, args):
    print("\n  Available commands:")
    print("  " + "─" * 40)
    for name, info in sorted(COMMANDS.items()):
        print(f"  /{name:12s}  {info['help']}")
    print(f"\n  Or just type naturally to chat with the agent.\n")


@command("clear", "Clear conversation history")
def cmd_clear(agent, args):
    agent.conversation.clear()
    print("  ✓ Conversation cleared.\n")


@command("read", "Read a file: /read <path>")
def cmd_read(agent, args):
    if not args:
        print("  Usage: /read <filepath>")
        return
    path = Path(args.strip())
    if not path.exists():
        print(f"  Error: File not found: {path}")
        return
    try:
        content = path.read_text()
        # Add file content to conversation context
        agent.conversation.add_user(
            f"Here is the contents of `{path}`:\n```\n{content}\n```"
        )
        if HAS_RICH:
            # Detect language from extension
            ext_map = {
                ".py": "python", ".js": "javascript", ".ts": "typescript",
                ".rs": "rust", ".go": "go", ".java": "java", ".cpp": "cpp",
                ".c": "c", ".rb": "ruby", ".sh": "bash", ".lean": "lean4",
                ".json": "json", ".yaml": "yaml", ".yml": "yaml",
                ".md": "markdown", ".html": "html", ".css": "css",
            }
            lang = ext_map.get(path.suffix, "text")
            console = Console()
            console.print(Panel(
                Syntax(content, lang, theme="monokai", line_numbers=True),
                title=str(path), border_style="blue"
            ))
        else:
            print(f"  ── {path} ──")
            print(content)
            print(f"  ── end ──")
        print(f"  ✓ File loaded into context ({len(content)} chars)\n")
    except Exception as e:
        print(f"  Error reading file: {e}")


@command("write", "Write to a file: /write <path>")
def cmd_write(agent, args):
    if not args:
        print("  Usage: /write <filepath>")
        print("  Then enter content, ending with a line containing only 'EOF'")
        return
    path = Path(args.strip())
    print(f"  Enter content for {path} (end with 'EOF' on its own line):")
    lines = []
    while True:
        line = input()
        if line.strip() == "EOF":
            break
        lines.append(line)
    content = "\n".join(lines)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    print(f"  ✓ Written {len(content)} chars to {path}\n")


@command("run", "Run a shell command: /run <command>")
def cmd_run(agent, args):
    if not args:
        print("  Usage: /run <shell command>")
        return
    try:
        result = subprocess.run(
            args.strip(), shell=True, capture_output=True, text=True, timeout=30,
        )
        output = result.stdout + result.stderr
        print(f"  Exit code: {result.returncode}")
        if output.strip():
            print(output)
        # Add to context
        agent.conversation.add_user(
            f"I ran `{args.strip()}` and got:\n```\n{output}\n```"
        )
    except subprocess.TimeoutExpired:
        print("  Error: Command timed out (30s limit)")
    except Exception as e:
        print(f"  Error: {e}")


@command("ls", "List directory contents: /ls [path]")
def cmd_ls(agent, args):
    path = Path(args.strip()) if args.strip() else Path(".")
    if not path.exists():
        print(f"  Error: {path} not found")
        return
    for item in sorted(path.iterdir()):
        prefix = "📁" if item.is_dir() else "📄"
        size = f" ({item.stat().st_size:,} bytes)" if item.is_file() else ""
        print(f"  {prefix} {item.name}{size}")
    print()


@command("model", "Show model information")
def cmd_model(agent, args):
    print(f"\n  Model: {agent.metadata.get('source_model', 'unknown')}")
    print(f"  Architecture: TropicalCausalLM")
    print(f"  Parameters: {agent.metadata.get('parameters', 'unknown'):,}")
    print(f"  Tropical temperature: {agent.metadata.get('final_temperature', '?')}")
    print(f"  Distilled: {agent.metadata.get('distilled', '?')}")
    print(f"  Device: {agent.config.effective_device()}")
    print()


@command("temp", "Set generation temperature: /temp <value>")
def cmd_temp(agent, args):
    try:
        t = float(args.strip())
        agent.config.temperature = t
        print(f"  ✓ Temperature set to {t}\n")
    except ValueError:
        print("  Usage: /temp <float>")


@command("exit", "Exit the agent")
def cmd_exit(agent, args):
    raise SystemExit


@command("save", "Save conversation to file: /save <path>")
def cmd_save(agent, args):
    path = Path(args.strip()) if args.strip() else Path("conversation.json")
    data = [{"role": m.role, "content": m.content} for m in agent.conversation.messages]
    path.write_text(json.dumps(data, indent=2))
    print(f"  ✓ Conversation saved to {path}\n")


@command("apply", "Extract and apply code from last response")
def cmd_apply(agent, args):
    """Extract code blocks from the last assistant message and offer to write them."""
    last_assistant = None
    for msg in reversed(agent.conversation.messages):
        if msg.role == "assistant":
            last_assistant = msg.content
            break

    if not last_assistant:
        print("  No assistant response to extract from.")
        return

    # Find code blocks
    blocks = re.findall(r"```(\w*)\n(.*?)```", last_assistant, re.DOTALL)
    if not blocks:
        print("  No code blocks found in last response.")
        return

    for i, (lang, code) in enumerate(blocks):
        print(f"\n  Block {i+1} ({lang or 'text'}, {len(code)} chars):")
        preview = "\n".join(code.split("\n")[:5])
        print(f"  {preview}")
        if len(code.split('\n')) > 5:
            print(f"  ... ({len(code.split(chr(10)))} lines total)")

        answer = input(f"  Write to file? Enter path or press Enter to skip: ").strip()
        if answer:
            path = Path(answer)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(code)
            print(f"  ✓ Written to {path}")


# ═══════════════════════════════════════════════════════════
#  Agent Core
# ═══════════════════════════════════════════════════════════

class TropicalAgent:
    """Interactive CLI agent powered by a tropical language model."""

    def __init__(self, config: AgentConfig):
        self.config = config
        self.device = config.effective_device()

        print(f"  Loading model from {config.model_path}...")
        self.model, self.tokenizer, self.arch_params, self.metadata = (
            load_tropical_model(config.model_path, self.device)
        )
        print(f"  ✓ Model loaded ({self.metadata.get('parameters', '?'):,} params)")

        self.conversation = Conversation(
            system_prompt=config.system_prompt,
            tokenizer=self.tokenizer,
            max_context=self.arch_params.get("max_position_embeddings", 4096),
        )

        # Set up console
        self.console = Console() if HAS_RICH else None

    def generate(self, prompt_tokens: torch.LongTensor) -> str:
        """Generate a response from the tropical model."""
        with torch.no_grad():
            output_ids = self.model.generate(
                prompt_tokens,
                max_new_tokens=self.config.max_tokens,
                temperature=self.config.temperature,
                top_p=self.config.top_p,
                top_k=self.config.top_k,
                do_sample=True,
                eos_token_id=self.tokenizer.eos_token_id,
            )

        # Decode only the new tokens
        new_tokens = output_ids[0, prompt_tokens.shape[1]:]
        response = self.tokenizer.decode(new_tokens, skip_special_tokens=True)
        return response.strip()

    def respond(self, user_input: str) -> str:
        """Process user input and generate a response."""
        self.conversation.add_user(user_input)
        prompt_tokens = self.conversation.to_token_ids(self.device)
        response = self.generate(prompt_tokens)
        self.conversation.add_assistant(response)
        return response

    def display_response(self, response: str):
        """Display the assistant's response with formatting."""
        if self.console and HAS_RICH:
            self.console.print()
            self.console.print(Markdown(response))
            self.console.print()
        else:
            print(f"\n{response}\n")

    def run(self):
        """Main REPL loop."""
        self._print_banner()

        # Set up history
        history = None
        if HAS_PROMPT_TOOLKIT:
            history_file = Path.home() / ".cache" / "tropicalize" / "agent_history"
            history_file.parent.mkdir(parents=True, exist_ok=True)
            history = FileHistory(str(history_file))

        while True:
            try:
                # Get input
                if HAS_PROMPT_TOOLKIT and history:
                    user_input = pt_prompt(
                        "🌴 > ",
                        history=history,
                        auto_suggest=AutoSuggestFromHistory(),
                    )
                else:
                    user_input = input("🌴 > ")

                user_input = user_input.strip()
                if not user_input:
                    continue

                # Handle slash commands
                if user_input.startswith("/"):
                    parts = user_input[1:].split(None, 1)
                    cmd_name = parts[0].lower()
                    cmd_args = parts[1] if len(parts) > 1 else ""

                    if cmd_name in COMMANDS:
                        COMMANDS[cmd_name]["func"](self, cmd_args)
                    else:
                        print(f"  Unknown command: /{cmd_name}. Type /help for commands.\n")
                    continue

                # Generate response
                start = time.time()
                response = self.respond(user_input)
                elapsed = time.time() - start

                self.display_response(response)

                # Show timing
                tokens = len(self.tokenizer.encode(response))
                tps = tokens / max(elapsed, 0.001)
                if HAS_RICH:
                    self.console.print(
                        f"  [dim]{tokens} tokens in {elapsed:.1f}s ({tps:.1f} tok/s)[/dim]"
                    )
                else:
                    print(f"  [{tokens} tokens in {elapsed:.1f}s ({tps:.1f} tok/s)]")

            except KeyboardInterrupt:
                print("\n  (Ctrl+C to interrupt, /exit to quit)")
                continue
            except EOFError:
                break
            except SystemExit:
                break

        print("\n  👋 Goodbye!\n")

    def _print_banner(self):
        source = self.metadata.get("source_model", "unknown")
        params = self.metadata.get("parameters", "?")

        banner = f"""
╔══════════════════════════════════════════════════════╗
║            🌴 Tropical Engineering Agent 🌴          ║
╠══════════════════════════════════════════════════════╣
║  Model  : {source:<41s} ║
║  Params : {str(params) + ' (tropical)' :<41s} ║
║  Device : {str(self.device):<41s} ║
╠══════════════════════════════════════════════════════╣
║  Type naturally to chat, or use slash commands:      ║
║  /help  /read <file>  /write <file>  /run <cmd>     ║
║  /ls    /model        /clear         /exit           ║
╚══════════════════════════════════════════════════════╝
"""
        if HAS_RICH:
            self.console.print(banner, style="green")
        else:
            print(banner)


# ═══════════════════════════════════════════════════════════
#  Entry Point
# ═══════════════════════════════════════════════════════════

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Tropical CLI Software Engineering Agent",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        "model_path",
        help="Path to the tropical model directory (output of convert_model.py)",
    )

    parser.add_argument(
        "--temperature", "-t", type=float, default=0.7,
        help="Generation temperature (default: 0.7)",
    )
    parser.add_argument(
        "--top-p", type=float, default=0.9,
        help="Nucleus sampling top-p (default: 0.9)",
    )
    parser.add_argument(
        "--top-k", type=int, default=50,
        help="Top-k sampling (default: 50)",
    )
    parser.add_argument(
        "--max-tokens", type=int, default=2048,
        help="Maximum tokens to generate per response (default: 2048)",
    )
    parser.add_argument(
        "--system", "-s", type=str, default=None,
        help="Custom system prompt",
    )
    parser.add_argument(
        "--device", type=str, default="auto",
        help="Device: auto, cpu, cuda, mps (default: auto)",
    )

    return parser.parse_args()


def main():
    args = parse_args()

    config = AgentConfig(
        model_path=args.model_path,
        temperature=args.temperature,
        top_p=args.top_p,
        top_k=args.top_k,
        max_tokens=args.max_tokens,
        device=args.device,
    )

    if args.system:
        config.system_prompt = args.system

    agent = TropicalAgent(config)
    agent.run()


if __name__ == "__main__":
    main()
