#!/usr/bin/env python3
"""ComputationalStage: recommended pre-proof experimentation for Aristotle.

Before attempting a formal proof, Aristotle is encouraged to:
  1. Compute small cases / examples
  2. Search OEIS for matching sequences
  3. Plot or tabulate data
  4. Hunt for counterexamples

If evidence contradicts the conjecture, the proof attempt is aborted.
If Aristotle skips the stage, it must provide written justification.
"""

import re
import subprocess
import tempfile
from pathlib import Path
from typing import Dict, Optional


class ComputationalStage:
    """Run Python computational evidence in a sandboxed subprocess."""

    def __init__(self, timeout: int = 60, max_output_chars: int = 10000):
        self.timeout = timeout
        self.max_output_chars = max_output_chars

    def run(self, code: str, preamble: str = "") -> Dict[str, str]:
        """Execute Python code and return stdout/stderr/success."""
        if not code or not code.strip():
            return {"success": True, "stdout": "", "stderr": ""}

        # Restrict imports / operations that could harm the host
        blocked_patterns = [
            r"\bopen\s*\(",
            r"\bos\.(system|popen|spawn|exec)",
            r"\bsubprocess\.",
            r"\b__import__\s*\(",
            r"\beval\s*\(",
            r"\bexec\s*\(",
        ]
        for pat in blocked_patterns:
            if re.search(pat, code):
                return {
                    "success": False,
                    "stdout": "",
                    "stderr": f"Security: blocked pattern '{pat}' in computational stage code",
                }

        script = preamble + "\n" + code if preamble else code
        try:
            with tempfile.NamedTemporaryFile("w", suffix=".py", delete=False) as f:
                f.write(script)
                tmp_path = Path(f.name)
            result = subprocess.run(
                ["python3", str(tmp_path)],
                capture_output=True,
                text=True,
                timeout=self.timeout,
            )
            stdout = result.stdout[:self.max_output_chars]
            stderr = result.stderr[:self.max_output_chars]
            success = result.returncode == 0
            return {"success": success, "stdout": stdout, "stderr": stderr}
        except subprocess.TimeoutExpired:
            return {"success": False, "stdout": "", "stderr": f"Timeout after {self.timeout}s"}
        except Exception as e:
            return {"success": False, "stdout": "", "stderr": f"Sandbox error: {e}"}
        finally:
            try:
                tmp_path.unlink(missing_ok=True)
            except Exception:
                pass

    def augment_prompt(self, base_prompt: str) -> str:
        """Append a section requesting computational evidence before formal proof."""
        section = """

### Computational Evidence Stage (Recommended)

Before writing the formal Lean 4 proof, you are strongly encouraged to produce
computational evidence for the claim. Create a file named `ComputationalEvidence.md`
in the project directory with:

1. **Small-case calculations** — compute the first several instances of the object/conjecture.
2. **OEIS search results** — if a sequence appears, note its OEIS ID and first terms.
3. **Counterexample hunt** — test the universal claim on a representative sample; report any counterexample found.
4. **Plots or tables** — include any relevant visual/numerical data.

If you choose to skip this stage, you MUST explicitly justify why computational
evidence is unnecessary or infeasible in a `SkipEvidenceJustification.md` file.

Do not let the evidence stage dominate the project; keep it concise and directly
relevant to the theorem you intend to prove.
"""
        return base_prompt + section

    def extract_code_blocks(self, text: str) -> list:
        """Extract python code blocks from markdown text."""
        pattern = re.compile(r"```python\n(.*?)\n```", re.DOTALL)
        return pattern.findall(text)

    def run_markdown_code(self, text: str) -> Dict[str, str]:
        """Run all python code blocks in a markdown string and return merged output."""
        blocks = self.extract_code_blocks(text)
        if not blocks:
            return {"success": True, "stdout": "", "stderr": "", "blocks_run": 0}
        outputs = []
        errors = []
        all_success = True
        for code in blocks:
            result = self.run(code)
            outputs.append(result["stdout"])
            if result["stderr"]:
                errors.append(result["stderr"])
            if not result["success"]:
                all_success = False
        return {
            "success": all_success,
            "stdout": "\n---\n".join(outputs),
            "stderr": "\n---\n".join(errors),
            "blocks_run": len(blocks),
        }
