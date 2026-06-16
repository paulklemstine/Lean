#!/usr/bin/env python3
"""TheoremExtractor: parse Lean 4 source into structured theorem records.

Extracts declarations (theorem, lemma, example, etc.), their docstrings,
full statements, proof bodies, line numbers, and completeness flags.
"""

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional


@dataclass
class TheoremRecord:
    name: str
    file_hash: str = ""
    project_id: str = ""
    domain: str = "Unknown"
    declaration_kind: str = "theorem"  # theorem, lemma, example, def, etc.
    statement_text: str = ""  # short preview (old field)
    full_statement: str = ""  # statement up to `:=`
    proof_text: str = ""  # body after `:=`
    docstring: str = ""  # preceding /-! or /-- block, or adjacent -- lines
    line_number: int = 0
    file_path: str = ""
    is_sorry: bool = False
    uses_sorry: bool = False
    is_complete: bool = False
    parameters: str = ""  # text between name and `:`
    return_type: str = ""  # text between `:` and `:=`
    metadata_json: Dict = field(default_factory=dict)


class TheoremExtractor:
    """Extract structured theorem records from Lean 4 source text."""

    # Match top-level theorem/lemma/example declarations.
    # We intentionally avoid declarations nested inside defs/classes by only
    # matching at the start of a line with no leading whitespace.
    # `example` has no name, so the name group is optional.
    DECL_RE = re.compile(
        r"^(?:theorem|lemma|nonrec theorem|protected theorem|private theorem)\s+(\w+)|^(example)(?=\s*:)",
        re.MULTILINE,
    )

    # All block/line comment patterns used for docstring extraction.
    DOC_RE = re.compile(
        r"(?P<doc>/[-][-!]\s.*?-/|/-\s.*?-/|/--\s.*$)",
        re.DOTALL | re.MULTILINE,
    )

    def __init__(self, catalog_root: Optional[Path] = None):
        self.catalog_root = catalog_root

    def _extract_domain_from_path(self, rel_path: str) -> str:
        """Infer catalog domain from a relative path like 'Catalog/Algebra/Foo.lean'.

        Handles temporary extraction prefixes such as 'abc123_aristotle/Catalog/...'.
        """
        parts = Path(rel_path).parts
        for i, part in enumerate(parts):
            if part.lower() == "catalog" and i + 1 < len(parts):
                return parts[i + 1]
        if parts:
            return parts[0]
        return "Unknown"

    def _line_number(self, text: str, pos: int) -> int:
        """Return 1-based line number for character position."""
        return text.count("\n", 0, pos) + 1

    def _find_docstring(self, text: str, decl_start: int) -> str:
        """Find the docstring / comment block immediately preceding a declaration.

        Walks backwards from decl_start, collecting contiguous comment-only lines
        and the last `/-- ... -/` or `/-! ... -/` block.
        """
        lines = text[:decl_start].splitlines(keepends=True)
        docs: List[str] = []
        i = len(lines)
        while i > 0:
            i -= 1
            line = lines[i]
            stripped = line.strip()
            if stripped.startswith("/--") or stripped.startswith("/-!"):
                # block docstring: find matching -/
                block_lines = [line]
                while i > 0 and "-/" not in block_lines[-1]:
                    i -= 1
                    block_lines.append(lines[i])
                docs.append("".join(reversed(block_lines)))
                break  # stop after a leading block docstring
            if stripped.startswith("/-") and not stripped.startswith("/-!"):
                block_lines = [line]
                while i > 0 and "-/" not in block_lines[-1]:
                    i -= 1
                    block_lines.append(lines[i])
                docs.append("".join(reversed(block_lines)))
                continue
            if stripped.startswith("--"):
                docs.append(stripped)
                continue
            if stripped == "":
                continue
            # hit real code: stop
            break
        docs.reverse()
        # Clean up
        cleaned = []
        for d in docs:
            d = d.strip()
            if d.startswith("/-") and d.endswith("-/"):
                # strip comment delimiters and leading `*` or `-` per line
                inner = d[2:-2]
                inner_lines = []
                for ln in inner.splitlines():
                    ln = ln.strip()
                    if ln.startswith("*"):
                        ln = ln[1:].strip()
                    elif ln.startswith("-"):
                        ln = ln[1:].strip()
                    inner_lines.append(ln)
                cleaned.append("\n".join(inner_lines).strip())
            elif d.startswith("--"):
                cleaned.append(d[2:].strip())
            else:
                cleaned.append(d)
        return "\n".join(cleaned).strip()

    def _split_statement_proof(self, text: str, name_end: int) -> tuple:
        """Split text after declaration name into statement and proof body.

        Returns (full_statement, proof_text). The split point is the first
        top-level `:=` after the declaration name. The proof body stops at the
        next top-level declaration or end of file.
        """
        rest = text[name_end:]
        # Find `:=` that is not inside a string or nested parentheses.
        depth = 0
        in_string = False
        string_char = ""
        i = 0
        split_pos = None
        while i < len(rest):
            c = rest[i]
            if in_string:
                if c == string_char and (i == 0 or rest[i - 1] != "\\"):
                    in_string = False
                i += 1
                continue
            if c in ('"', "'"):
                in_string = True
                string_char = c
                i += 1
                continue
            if c == "(":
                depth += 1
            elif c == ")":
                depth -= 1
            elif c == ":" and i + 1 < len(rest) and rest[i + 1] == "=" and depth == 0:
                split_pos = i
                break
            i += 1

        if split_pos is None:
            return rest.strip(), ""

        full_statement = rest[:split_pos].strip()
        proof_start = name_end + split_pos + 2

        # Find where the proof body ends: next top-level declaration.
        next_match = self.DECL_RE.search(text, proof_start)
        if next_match:
            proof_end = next_match.start()
        else:
            proof_end = len(text)
        proof_text = text[proof_start:proof_end].strip()
        return full_statement, proof_text

    def _parse_parameters_return_type(self, full_statement: str) -> tuple:
        """Split a theorem statement into parameters and return type.

        e.g. `(x : Nat) (y : Nat) : x + y = y + x`
             => parameters: `(x : Nat) (y : Nat)`, return_type: `x + y = y + x`
        """
        # Find the top-level colon separating parameters from the proposition.
        depth = 0
        in_string = False
        colon_pos = None
        for i, c in enumerate(full_statement):
            if c in ('"', "'"):
                in_string = not in_string
                continue
            if in_string:
                continue
            if c in "(<{«":
                depth += 1
            elif c in ")>}»":
                depth -= 1
            elif c == ":" and depth == 0:
                colon_pos = i
                break
        if colon_pos is None:
            return "", full_statement.strip()
        parameters = full_statement[:colon_pos].strip()
        return_type = full_statement[colon_pos + 1:].strip()
        return parameters, return_type

    def extract_from_text(
        self,
        text: str,
        file_hash: str = "",
        file_path: str = "",
        project_id: str = "",
    ) -> List[TheoremRecord]:
        """Extract theorem records from Lean source text."""
        records = []
        for m in self.DECL_RE.finditer(text):
            name = m.group(1) if m.group(1) else m.group(2)
            decl_start = m.start()
            name_end = m.end()
            line_number = self._line_number(text, decl_start)
            full_statement, proof_text = self._split_statement_proof(text, name_end)
            docstring = self._find_docstring(text, decl_start)
            parameters, return_type = self._parse_parameters_return_type(full_statement)
            kind = (
                "example" if m.group(2)
                else "lemma" if "lemma" in m.group(0).lower()
                else "theorem"
            )
            lower_proof = proof_text.lower()
            uses_sorry = "sorry" in lower_proof or "admit" in lower_proof
            is_complete = bool(not uses_sorry and proof_text and not proof_text.startswith("_"))
            statement_preview = full_statement[:200].strip()
            is_sorry = "sorry" in statement_preview.lower()

            record = TheoremRecord(
                name=name,
                file_hash=file_hash,
                project_id=project_id,
                domain=self._extract_domain_from_path(file_path),
                declaration_kind=kind,
                statement_text=statement_preview,
                full_statement=full_statement[:4000],
                proof_text=proof_text[:4000],
                docstring=docstring[:4000],
                line_number=line_number,
                file_path=file_path,
                is_sorry=is_sorry,
                uses_sorry=uses_sorry,
                is_complete=is_complete,
                parameters=parameters[:1000],
                return_type=return_type[:1000],
                metadata_json={
                    "declaration_prefix": m.group(0),
                    "file_path": file_path,
                },
            )
            records.append(record)
        return records

    def extract_from_bytes(
        self,
        data: bytes,
        file_hash: str = "",
        file_path: str = "",
        project_id: str = "",
    ) -> List[TheoremRecord]:
        text = data.decode("utf-8", errors="replace")
        return self.extract_from_text(text, file_hash, file_path, project_id)

    def records_to_db_rows(self, records: List[TheoremRecord]) -> List[Dict]:
        """Convert TheoremRecords to dicts ready for archive_manager insert."""
        import json
        rows = []
        for r in records:
            rows.append({
                "name": r.name,
                "file_hash": r.file_hash,
                "project_id": r.project_id,
                "domain": r.domain,
                "statement_text": r.statement_text,
                "full_statement": r.full_statement,
                "proof_text": r.proof_text,
                "docstring": r.docstring,
                "line_number": r.line_number,
                "file_path": r.file_path,
                "theorem_type": r.declaration_kind,
                "declaration_kind": r.declaration_kind,
                "is_sorry": int(r.is_sorry),
                "uses_sorry": int(r.uses_sorry),
                "is_complete": int(r.is_complete),
                "parameters": r.parameters,
                "return_type": r.return_type,
                "metadata_json": json.dumps(r.metadata_json, ensure_ascii=False),
            })
        return rows


if __name__ == "__main__":
    import sys
    sample = r'''
import Mathlib

/-! This file proves trivial things. -/

/-- Reflexivity for natural numbers. -/
theorem nat_refl (n : Nat) : n = n := by
  rfl

/- A plain comment -/
lemma nat_symm {n m : Nat} : n = m → m = n := by
  intro h
  exact h.symm

example : 1 + 1 = 2 := by
  norm_num
'''
    extractor = TheoremExtractor()
    for rec in extractor.extract_from_text(sample, file_hash="abc", file_path="Catalog/Algebra/Test.lean"):
        print(rec)
