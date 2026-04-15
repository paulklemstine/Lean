#!/usr/bin/env python3
"""Extract declarations from Lean 4 source files into a catalog database.

Scans all .lean files under a catalog root, parses declarations
(theorem/def/structure etc.), resolves duplicates, and outputs
a JSON database that serves as the single source of truth for
the build system.
"""

import argparse
import json
import os
import re
import sys
import time
import uuid
from collections import defaultdict
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Optional


# ── Regex patterns ──────────────────────────────────────────────────

# Use \s* instead of ^ to match indented declarations inside namespace/section blocks
DECL_PATTERNS = [
    (re.compile(r'^(\s*)(noncomputable\s+)?def\s+(\S+)', re.MULTILINE), 'def', 3),
    (re.compile(r'^(\s*)(noncomputable\s+)?theorem\s+(\S+)', re.MULTILINE), 'theorem', 3),
    (re.compile(r'^(\s*)lemma\s+(\S+)', re.MULTILINE), 'lemma', 2),
    (re.compile(r'^(\s*)structure\s+(\S+)', re.MULTILINE), 'structure', 2),
    (re.compile(r'^(\s*)class\s+(\S+)', re.MULTILINE), 'class', 2),
    (re.compile(r'^(\s*)inductive\s+(\S+)', re.MULTILINE), 'inductive', 2),
    # instance can have a name or be anonymous: "instance foo : ..." or "instance : ..."
    (re.compile(r'^(\s*)instance\s+(\S+?)\s*:', re.MULTILINE), 'instance', 2),
    (re.compile(r'^(\s*)instance\s*:', re.MULTILINE), 'instance', 0),
    (re.compile(r'^(\s*)axiom\s+(\S+)', re.MULTILINE), 'axiom', 2),
    (re.compile(r'^(\s*)abbrev\s+(\S+)', re.MULTILINE), 'abbrev', 2),
]

# For quick line-by-line matching (no regex needed for start-of-line keywords)
DECL_KEYWORDS = {'def', 'theorem', 'lemma', 'structure', 'class', 'inductive',
                 'instance', 'axiom', 'abbrev', 'noncomputable'}

NAMESPACE_OPEN = re.compile(r'^\s*namespace\s+(\S+)')
NAMESPACE_CLOSE = re.compile(r'^\s*end\s+(\S+)')

IMPORT_LINE = re.compile(r'^import\s+(\S+)')

# Block comment patterns: /-! ... -/ and /-- ... -/
BLOCK_COMMENT_START = re.compile(r'^/-(!|-)')
BLOCK_COMMENT_END = re.compile(r'-/')

SORRY_PATTERN = re.compile(r'\bsorry\b')

TACTIC_KEYWORDS = [
    'ring', 'linarith', 'nlinarith', 'omega', 'simp', 'simpa',
    'norm_num', 'native_decide', 'positivity', 'rw', 'rwa',
    'exact', 'intro', 'intros', 'cases', 'induction', 'ext',
    'rfl', 'decide', 'unfold', 'norm_cast', 'push_cast',
    'have', 'constructor', 'left', 'right', 'apply', 'funext',
    'field_simp', 'ring_nf', 'fin_cases', 'aesop', 'tauto',
    'trivial', 'contradiction', 'exfalso', 'assumption',
    'refine', 'rcases', 'obtain', 'use', 'split', 'exists',
    'convert', 'convert_to', 'change', 'show', 'by_contra',
    'by_cases', 'wlog', 'suffices', 'trans', 'calc',
]

TACTIC_PATTERNS = {t: re.compile(rf'\b{t}\b') for t in TACTIC_KEYWORDS}


@dataclass
class CatalogEntry:
    id: str = ""
    name: str = ""
    qualified_name: str = ""
    kind: str = ""
    namespace: str = ""
    source_file: str = ""
    module_path: str = ""
    line_number: int = 0
    end_line: int = 0
    type_signature: str = ""
    doc_comment: Optional[str] = None
    description: Optional[str] = None
    body: str = ""
    domain: str = ""
    subdomain: Optional[str] = None
    imports: list = field(default_factory=list)
    internal_imports: list = field(default_factory=list)
    proof_tactics: list = field(default_factory=list)
    sorry_count: int = 0
    proof_length_lines: int = 0
    is_noncomputable: bool = False
    canonical: bool = True
    duplicate_of: Optional[str] = None
    duplicate_group_id: Optional[str] = None
    source_provenance: str = ""


def path_to_module(rel_path: str, prefix: str = "Catalog") -> str:
    """Convert relative file path to Lean module path."""
    p = Path(rel_path)
    parts = list(p.parts)
    if parts and parts[-1].endswith('.lean'):
        parts[-1] = parts[-1][:-5]
    return prefix + "." + ".".join(parts)


# Domain consolidation: 28 original domains → 12 categories
DOMAIN_MAP = {
    'Algebra': 'Algebra',
    'NumberTheory': 'Algebra',
    'CategoryTheory': 'Algebra',
    'Analysis': 'Algebra',
    'Probability': 'Algebra',
    'Combinatorics': 'Algebra',
    'Topology': 'Algebra',
    'Geometry': 'Geometry',
    'GravitationalFactoring': 'Geometry',
    'Logic': 'Logic',
    'ComplexityTheory': 'Logic',
    'Physics': 'Physics',
    'GravitationalFactoringResearch': 'Physics',
    'Computation': 'Computation',
    'InformationTheory': 'Computation',
    'OISCC': 'Computation',
    'Cryptography': 'Cryptography',
    'Bridges': 'Bridges',
    'Pythagorean': 'Pythagorean',
    'SPBBridge': 'Pythagorean',
    'Tropical': 'Tropical',
    'EML': 'EML',
    'ShefferAI': 'EML',
    'MachineLearning': 'MachineLearning',
    'NeuralCompilation': 'MachineLearning',
    'Speculative': 'Speculative',
    'FutureResearch': 'Speculative',
    'New': 'Speculative',
}


def path_to_domain(rel_path: str) -> tuple:
    """Extract (domain, subdomain) from relative path.

    Domains are consolidated into 12 categories via DOMAIN_MAP.
    The subdomain preserves the original domain for granularity.
    """
    parts = Path(rel_path).parts
    original_domain = parts[0] if parts else ""
    subdomain = parts[1] if len(parts) > 2 else None
    domain = DOMAIN_MAP.get(original_domain, original_domain)
    return domain, subdomain


def find_canonical_entry(entries: list) -> CatalogEntry:
    """Select the canonical entry from a group of duplicates.

    Priority: sorry-free > in Best/ > shortest path > alphabetical
    """
    def sort_key(e: CatalogEntry):
        return (
            e.sorry_count,
            0 if e.source_file.startswith("Best/") else 1,
            len(Path(e.source_file).parts),
            e.source_file
        )
    return min(entries, key=sort_key)


class LeanFileParser:
    """Parse a single .lean file and extract declarations.

    Uses a line-by-line state machine that:
    1. Skips block comments (/-! ... -/ and /-- ... -/)
    2. Tracks namespace nesting
    3. Detects declaration starts via keyword matching on stripped lines
    4. Captures declaration bodies by tracking indentation and nesting
    """

    def __init__(self, rel_path: str, content: str):
        self.rel_path = rel_path
        self.content = content
        self.lines = content.split('\n')
        self.module_path = path_to_module(rel_path)
        self.domain, self.subdomain = path_to_domain(rel_path)
        self.entries: list[CatalogEntry] = []
        self.imports: list[str] = []

    def parse(self) -> list[CatalogEntry]:
        """Parse the file and return extracted declarations."""
        self._extract_imports()
        self._parse_body()
        return self.entries

    def _extract_imports(self):
        for line in self.lines:
            m = IMPORT_LINE.match(line.strip())
            if m:
                self.imports.append(m.group(1))

    def _parse_body(self):
        """Main parsing loop."""
        lines = self.lines
        n = len(lines)

        # State
        namespace_stack: list[str] = []
        in_block_comment = False
        in_doc_comment = False
        in_module_comment = False  # /-! ... -/ module/section doc comment
        pending_doc: Optional[str] = None
        pending_line_comments: list[str] = []  # accumulated -- comments
        last_module_comment: Optional[str] = None  # most recent /-! section comment
        doc_lines: list[str] = []
        section_noncomputable_depth = 0  # depth of noncomputable section nesting
        section_depth = 0  # total section nesting depth

        i = 0
        while i < n:
            line = lines[i]
            stripped = line.strip()

            # Skip empty lines
            if not stripped:
                i += 1
                continue

            # Block comment handling (/-! ... -/ and /-- ... -/)
            if in_block_comment:
                if BLOCK_COMMENT_END.search(stripped):
                    in_block_comment = False
                    # If this was a doc comment, save it
                    if in_doc_comment:
                        doc_lines.append(stripped)
                        full = '\n'.join(doc_lines)
                        # Strip wrapper
                        full = re.sub(r'^/-[!-]\s*', '', full, count=1)
                        full = re.sub(r'\s*-/$', '', full, count=1)
                        pending_doc = full.strip()
                        in_doc_comment = False
                        doc_lines = []
                    elif in_module_comment:
                        doc_lines.append(stripped)
                        full = '\n'.join(doc_lines)
                        full = re.sub(r'^/-[!-]\s*', '', full, count=1)
                        full = re.sub(r'\s*-/$', '', full, count=1)
                        last_module_comment = full.strip()
                        in_module_comment = False
                        doc_lines = []
                else:
                    if in_doc_comment or in_module_comment:
                        doc_lines.append(stripped)
                i += 1
                continue

            # Check for block comment start (/-! ... -/, /-- ... -/, and /- ... -/)
            # All Lean 4 block comments start with /-
            if stripped.startswith('/-'):
                in_block_comment = True
                if stripped.startswith('/--'):
                    in_doc_comment = True
                elif stripped.startswith('/-!'):
                    in_module_comment = True
                doc_lines = [stripped]
                # Check if the comment ends on the same line
                if BLOCK_COMMENT_END.search(stripped):
                    in_block_comment = False
                    if in_doc_comment:
                        full = '\n'.join(doc_lines)
                        full = re.sub(r'^/-[!-]\s*', '', full, count=1)
                        full = re.sub(r'\s*-/$', '', full, count=1)
                        pending_doc = full.strip()
                        in_doc_comment = False
                        doc_lines = []
                    elif in_module_comment:
                        full = '\n'.join(doc_lines)
                        full = re.sub(r'^/-[!-]\s*', '', full, count=1)
                        full = re.sub(r'\s*-/$', '', full, count=1)
                        last_module_comment = full.strip()
                        in_module_comment = False
                        doc_lines = []
                i += 1
                continue

            # Collect line comments (--) immediately before declarations
            if stripped.startswith('--'):
                comment_text = stripped[2:].strip()
                pending_line_comments.append(comment_text)
                i += 1
                continue

            # Import lines (should only be at top, but handle anywhere)
            if stripped.startswith('import '):
                i += 1
                continue

            # Namespace tracking
            ns_match = NAMESPACE_OPEN.match(line)
            if ns_match:
                namespace_stack.append(ns_match.group(1))
                i += 1
                continue

            ns_close = NAMESPACE_CLOSE.match(line)
            if ns_close:
                # Check if it closes a namespace (not a theorem/def name)
                closed_name = ns_close.group(1)
                if namespace_stack and namespace_stack[-1] == closed_name:
                    namespace_stack.pop()
                i += 1
                continue

            # Section/open tracking
            if re.match(r'^\s*(noncomputable\s+)?section\b', stripped):
                if 'noncomputable' in stripped:
                    section_noncomputable_depth += 1
                section_depth += 1
                i += 1
                continue

            if re.match(r'^\s*end\s*$', stripped) and section_depth > 0:
                if section_noncomputable_depth > 0:
                    section_noncomputable_depth -= 1
                section_depth -= 1
                i += 1
                continue

            # Declaration detection
            decl_info = self._detect_declaration(stripped, section_noncomputable_depth > 0)
            if decl_info:
                name, kind, is_noncomp = decl_info
                start_line = i + 1  # 1-indexed

                # Capture doc comment if pending
                doc = pending_doc
                pending_doc = None

                # Build description from all available comment context
                description = self._build_description(
                    doc, pending_line_comments, last_module_comment)

                # Clear accumulated line comments and consumed module comment
                pending_line_comments = []
                # Module comment attaches to the first declaration after it;
                # don't repeat it for subsequent declarations
                if last_module_comment and not doc:
                    last_module_comment = None

                # Find end of declaration body
                end_line = self._find_decl_end(i)
                body_lines = lines[i:end_line + 1]
                body = '\n'.join(body_lines)

                # Extract type signature
                sig = self._extract_signature(body, name)

                # Extract tactics
                tactics = self._extract_tactics(body)

                # Count sorry
                sorry_count = len(SORRY_PATTERN.findall(body))

                # Compute namespace
                ns = '.'.join(namespace_stack) if namespace_stack else ''
                qname = f"{ns}.{name}" if ns else name

                # Internal imports
                internal = [imp for imp in self.imports if imp.startswith('Catalog.')]

                entry = CatalogEntry(
                    id=str(uuid.uuid4()),
                    name=name,
                    qualified_name=qname,
                    kind=kind,
                    namespace=ns,
                    source_file=self.rel_path,
                    module_path=self.module_path,
                    line_number=start_line,
                    end_line=end_line + 1,
                    type_signature=sig,
                    doc_comment=doc,
                    description=description,
                    body=body,
                    domain=self.domain,
                    subdomain=self.subdomain,
                    imports=list(self.imports),
                    internal_imports=internal,
                    proof_tactics=tactics,
                    sorry_count=sorry_count,
                    proof_length_lines=len(body_lines),
                    is_noncomputable=is_noncomp,
                    canonical=True,
                    source_provenance=self.rel_path,
                )
                self.entries.append(entry)
                i = end_line + 1
                continue

            # Non-declaration line: clear accumulated line comments
            # (they only attach to the immediately next declaration)
            pending_line_comments = []

            i += 1

    def _build_description(self, doc_comment: Optional[str],
                           line_comments: list[str],
                           module_comment: Optional[str]) -> Optional[str]:
        """Build a human-readable description from all comment sources.

        Priority: doc_comment > line_comments > module_comment context.
        """
        # /-- ... -/ doc comment is the best description
        if doc_comment:
            return doc_comment

        # -- line comments immediately before the declaration
        # Filter out decorative separators (lines of only -, =, *, #)
        meaningful = [c for c in line_comments
                     if not re.match(r'^[-=*#]+\s*$', c) and len(c.strip()) > 0]
        if meaningful:
            return ' '.join(meaningful)

        # /-! ... -/ section/module comment as context
        if module_comment:
            return f'[Section: {module_comment}]'

        return None

    def _detect_declaration(self, stripped: str, in_noncomp_section: bool) -> Optional[tuple]:
        """Detect a declaration keyword on a stripped line.

        Returns (name, kind, is_noncomputable) or None.
        """
        # Check for noncomputable prefix
        is_noncomp = in_noncomp_section
        working = stripped

        if working.startswith('noncomputable '):
            is_noncomp = True
            working = working[len('noncomputable '):]

        # Now check for declaration keywords
        for keyword, kind in [('theorem', 'theorem'), ('lemma', 'lemma'),
                              ('def', 'def'), ('structure', 'structure'),
                              ('class', 'class'), ('inductive', 'inductive'),
                              ('axiom', 'axiom'), ('abbrev', 'abbrev')]:
            if working.startswith(keyword + ' '):
                rest = working[len(keyword):].strip()
                # Extract name (first word, strip trailing colon/parens)
                name = rest.split()[0] if rest.split() else rest
                name = name.rstrip(':').rstrip('(').strip()
                if name:
                    actual_kind = kind
                    if is_noncomp and kind == 'def':
                        actual_kind = 'noncomputable_def'
                    return (name, actual_kind, is_noncomp)
            elif working == keyword:
                # Bare keyword on a line (rare but possible)
                pass

        # Instance is special: can be "instance foo : ..." or "instance : ..."
        if working.startswith('instance '):
            rest = working[len('instance'):].strip()
            if rest.startswith(':'):
                # Anonymous instance: "instance : ..."
                return ('_anonymous_instance', 'instance', is_noncomp)
            else:
                # Named instance: "instance foo : ..."
                name = rest.split()[0] if rest.split() else rest
                name = name.rstrip(':').strip()
                if name and name != ':':
                    return (name, 'instance', is_noncomp)

        if working.startswith('instance:'):
            return ('_anonymous_instance', 'instance', is_noncomp)

        return None

    def _find_decl_end(self, start_idx: int) -> int:
        """Find the last line index of the declaration starting at start_idx.

        Strategy: Scan forward from start_idx, tracking nesting depth.
        A declaration ends when:
        - We hit a line at the same or lesser indentation that starts a new declaration
        - We hit a namespace/end/section at base indentation
        - We hit an unindented blank line followed by another declaration-like line

        The tricky part is proof blocks (by ... tactics) and where clauses.
        We track nesting via indentation changes.
        """
        lines = self.lines
        n = len(lines)

        if start_idx >= n:
            return start_idx

        # Get the indentation of the declaration keyword line
        base_indent = len(lines[start_idx]) - len(lines[start_idx].lstrip())

        # Check if the declaration line itself contains := or ends with 'by'
        # (one-liner or body-starts-on-same-line pattern)
        start_stripped = lines[start_idx].strip()
        body_on_start_line = ':=' in start_stripped or start_stripped.endswith(' by') or start_stripped == 'by'

        if body_on_start_line:
            # The body starts on the declaration line itself.
            # Scan forward from the next line to find where the body ends.
            return self._find_body_end(start_idx + 1, base_indent, start_idx)

        # Find the signature line (may span multiple lines)
        # The signature ends when we hit := or a "by" keyword at the end
        sig_indent = base_indent
        found_body_start = False
        i = start_idx + 1
        paren_depth = 0  # Track () nesting in signatures

        while i < n:
            stripped = lines[i].strip()

            # Skip blank lines and comments within the first few lines
            if not stripped or stripped.startswith('--'):
                i += 1
                continue

            # Block comments at base_indent end the declaration signature;
            # indented block comments are skipped (part of the signature)
            if stripped.startswith('/-'):
                bc_indent = len(lines[i]) - len(lines[i].lstrip())
                if bc_indent <= base_indent:
                    # Block comment at base indent — declaration ends before it
                    return i - 1
                # Indented block comment: skip it
                if BLOCK_COMMENT_END.search(stripped):
                    # Single-line block comment: /- ... -/
                    i += 1
                    continue
                # Multi-line block comment: skip until -/
                i += 1
                while i < n:
                    if BLOCK_COMMENT_END.search(lines[i].strip()):
                        i += 1
                        break
                    i += 1
                continue

            current_indent = len(lines[i]) - len(lines[i].lstrip())

            # Track parentheses for multi-line signatures
            paren_depth += stripped.count('(') - stripped.count(')')

            # Check for := which starts the body
            if ':=' in stripped:
                found_body_start = True

            # Check for "by" at end of line (proof start)
            if stripped.endswith(' by') or stripped == 'by':
                found_body_start = True

            # Once we've found the body start, track indentation to find the end
            if found_body_start:
                # Look for the end of the proof/body
                return self._find_body_end(i, base_indent, start_idx)

            # If we're still in the signature and the indent drops back
            # to base or less, check if this is a new declaration.
            # We check from i > start_idx (not i > start_idx + 1) because
            # a one-liner without := followed by another declaration on the
            # very next line is a valid boundary.
            if current_indent <= base_indent and i > start_idx and paren_depth <= 0:
                # Check if this line is a new declaration
                if self._line_starts_declaration(stripped):
                    return i - 1
                # Otherwise this might be a continuation at base indent
                # (unlikely for signatures)

            i += 1

        return n - 1

    def _find_body_end(self, body_start_idx: int, base_indent: int, decl_start_idx: int) -> int:
        """Find the end of a declaration body starting from the proof/body start.

        The body ends when we return to base_indent or less with a new declaration
        keyword, or when we hit a namespace/end/section at base indent.
        Block comments (/- ... -/) are skipped entirely.
        """
        lines = self.lines
        n = len(lines)

        i = body_start_idx

        while i < n:
            stripped = lines[i].strip()

            if not stripped or stripped.startswith('--'):
                i += 1
                continue

            # Block comments at base_indent end the declaration;
            # indented block comments are part of the proof body
            if stripped.startswith('/-'):
                current_indent_bc = len(lines[i]) - len(lines[i].lstrip())
                if current_indent_bc <= base_indent:
                    # Block comment at base indent — declaration ends before it
                    return i - 1
                # Indented block comment: skip it (it's inside the proof)
                if BLOCK_COMMENT_END.search(stripped):
                    # Single-line block comment: /- ... -/
                    i += 1
                    continue
                # Multi-line block comment: skip until -/
                i += 1
                while i < n:
                    if BLOCK_COMMENT_END.search(lines[i].strip()):
                        i += 1
                        break
                    i += 1
                continue

            current_indent = len(lines[i]) - len(lines[i].lstrip())

            # A line at base_indent or less that starts a new declaration
            # always ends the current declaration
            if current_indent <= base_indent:
                if self._line_starts_declaration(stripped):
                    return i - 1
                # namespace/end/section at base indent also ends the declaration
                if NAMESPACE_OPEN.match(lines[i]) or NAMESPACE_CLOSE.match(lines[i]):
                    return i - 1
                if re.match(r'^\s*(noncomputable\s+)?section\b', stripped):
                    return i - 1
                if re.match(r'^\s*end\s*$', stripped):
                    return i - 1
                # A bare `end X` at base indent (not inside a proof)
                # Only ends the declaration if it's closing a namespace
                # that wasn't opened within the declaration body
                ns_close = NAMESPACE_CLOSE.match(lines[i])
                if ns_close:
                    return i - 1

            i += 1

        return n - 1

    def _line_starts_declaration(self, stripped: str) -> bool:
        """Check if a stripped line starts a new declaration."""
        if stripped.startswith('noncomputable '):
            stripped = stripped[len('noncomputable '):]
        for kw in DECL_KEYWORDS:
            if stripped.startswith(kw + ' ') or stripped.startswith(kw + ':'):
                return True
        # instance without name
        if stripped.startswith('instance ') or stripped.startswith('instance:'):
            return True
        return False

    def _extract_signature(self, body: str, name: str) -> str:
        """Extract the type signature from a declaration body."""
        # Remove the declaration keyword prefix
        sig = body
        sig = re.sub(r'^(noncomputable\s+)?(theorem|lemma|def|structure|class|inductive|instance|axiom|abbrev)\s+', '', sig)
        # Remove noncomputable section prefix if present
        sig = re.sub(r'^noncomputable\s+', '', sig)
        # Remove the name
        if name != '_anonymous_instance':
            sig = re.sub(rf'^{re.escape(name)}\s*', '', sig, count=1)
        # Truncate at :=
        sig = re.split(r'\s*:=\s*', sig)[0]
        # Clean up and limit length
        sig = sig.strip()
        first_newline = sig.find('\n')
        if first_newline > 0 and first_newline < len(sig) - 1:
            first_line = sig[:first_newline].strip()
            if len(first_line) > 100:
                sig = first_line[:100] + ' ...'
            else:
                sig = first_line + ' ...'
        elif len(sig) > 150:
            sig = sig[:150] + ' ...'
        return sig

    def _extract_tactics(self, body: str) -> list[str]:
        """Extract tactic keywords used in the declaration body."""
        found = []
        for tactic, pattern in TACTIC_PATTERNS.items():
            if pattern.search(body):
                found.append(tactic)
        return found


def scan_catalog(catalog_root: str, verbose: bool = False) -> dict:
    """Scan all .lean files and extract declarations into a catalog database."""
    root = Path(catalog_root)
    all_entries = []
    all_imports = {}
    file_count = 0
    total_lines = 0

    # Collect all .lean files
    lean_files = sorted(root.rglob('*.lean'))
    # Exclude tools/ directory
    lean_files = [f for f in lean_files if 'tools' not in f.parts]

    if verbose:
        print(f"Found {len(lean_files)} .lean files to scan")

    for filepath in lean_files:
        rel_path = str(filepath.relative_to(root))
        try:
            content = filepath.read_text(encoding='utf-8')
        except Exception as e:
            if verbose:
                print(f"  WARNING: Could not read {rel_path}: {e}")
            continue

        file_count += 1
        total_lines += content.count('\n')

        parser = LeanFileParser(rel_path, content)
        entries = parser.parse()
        all_entries.extend(entries)
        all_imports[rel_path] = parser.imports

        if verbose and entries:
            print(f"  {rel_path}: {len(entries)} declarations")

    if verbose:
        no_decl = file_count - sum(1 for f in lean_files
                                    if any(e.source_file == str(f.relative_to(root))
                                           for e in all_entries))
        print(f"\n  {len(all_entries)} total declarations from {file_count} files")

    # Build import graph
    import_graph = build_import_graph(lean_files, root, all_imports)

    # Build domain stats
    domains = build_domain_stats(all_entries, lean_files, root)

    # Resolve duplicates
    entries, dup_groups = resolve_duplicates(all_entries)

    # Build bridge index
    bridge_index = build_bridge_index(root, all_entries)

    # Compute metadata
    kind_counts = defaultdict(int)
    sorry_total = 0
    for e in entries:
        kind_counts[e.kind] += 1
        sorry_total += e.sorry_count

    metadata = {
        "schema_version": "1.0.0",
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "lean_version": "v4.28.0",
        "mathlib_version": "v4.28.0",
        "total_files": file_count,
        "total_declarations": len(entries),
        "total_theorems": kind_counts.get('theorem', 0) + kind_counts.get('lemma', 0),
        "total_defs": kind_counts.get('def', 0) + kind_counts.get('noncomputable_def', 0),
        "total_structures": (kind_counts.get('structure', 0) + kind_counts.get('class', 0)
                           + kind_counts.get('inductive', 0)),
        "total_lines": total_lines,
        "total_sorry": sorry_total,
        "total_duplicate_groups": len(dup_groups),
        "total_canonical": sum(1 for e in entries if e.canonical),
        "file_fingerprints": file_fingerprints(str(root)),
    }

    catalog = {
        "metadata": metadata,
        "entries": [asdict(e) for e in entries],
        "domains": domains,
        "duplicate_groups": dup_groups,
        "import_graph": import_graph,
        "bridge_index": bridge_index,
    }

    return catalog


def resolve_duplicates(entries: list[CatalogEntry]) -> tuple:
    """Group entries by name, resolve duplicates, mark canonical."""
    name_groups = defaultdict(list)
    for e in entries:
        name_groups[e.name].append(e)

    dup_groups = []
    for name, group in name_groups.items():
        if len(group) <= 1:
            continue

        gid = f"dup_{name}"

        # Check if signatures match
        sigs = set()
        for e in group:
            sig = re.sub(r'\s+', ' ', e.type_signature.strip())
            sigs.add(sig)
        all_match = len(sigs) <= 1

        # Determine recommendation
        if all_match and len(group) >= 5:
            recommendation = "extract_to_shared"
        elif all_match:
            recommendation = "merge_into_best"
        else:
            recommendation = "flag_for_review"

        # Find canonical
        canonical = find_canonical_entry(group)

        # Mark entries
        group_entries = []
        for e in group:
            if e.id == canonical.id:
                e.canonical = True
                e.duplicate_of = None
                e.duplicate_group_id = gid
            else:
                e.canonical = False
                e.duplicate_of = canonical.id
                e.duplicate_group_id = gid

            group_entries.append({
                "entry_id": e.id,
                "source_file": e.source_file,
                "qualified_name": e.qualified_name,
                "type_signature": e.type_signature,
                "canonical": e.canonical,
                "signature_match": all_match,
            })

        dup_groups.append({
            "group_id": gid,
            "name": name,
            "occurrence_count": len(group),
            "entries": group_entries,
            "all_signatures_identical": all_match,
            "recommendation": recommendation,
        })

    return entries, dup_groups


def build_import_graph(lean_files: list[Path], root: Path, all_imports: dict) -> dict:
    """Build module-level import graph."""
    nodes = []
    edges = []

    for filepath in lean_files:
        rel_path = str(filepath.relative_to(root))
        module = path_to_module(rel_path)
        domain, _ = path_to_domain(rel_path)
        nodes.append({"module": module, "domain": domain})

        for imp in all_imports.get(rel_path, []):
            if imp.startswith('Catalog.'):
                edge_type = 'internal'
            elif imp.startswith('Mathlib.') or imp.startswith('Batteries.') or imp.startswith('Lean.') or imp.startswith('Init.'):
                edge_type = 'mathlib'
            else:
                edge_type = 'external'
            edges.append({"source": module, "target": imp, "edge_type": edge_type})

    return {"nodes": nodes, "edges": edges}


def build_domain_stats(entries: list[CatalogEntry], lean_files: list[Path], root: Path) -> dict:
    """Build per-domain statistics."""
    domain_files = defaultdict(set)
    for f in lean_files:
        rel = str(f.relative_to(root))
        domain, _ = path_to_domain(rel)
        domain_files[domain].add(rel)

    domain_decls = defaultdict(lambda: {
        'declaration_count': 0, 'theorem_count': 0, 'def_count': 0,
        'structure_count': 0, 'line_count': 0, 'sorry_count': 0,
    })

    for e in entries:
        d = domain_decls[e.domain]
        d['declaration_count'] += 1
        if e.kind in ('theorem', 'lemma'):
            d['theorem_count'] += 1
        elif e.kind in ('def', 'noncomputable_def'):
            d['def_count'] += 1
        elif e.kind in ('structure', 'class', 'inductive'):
            d['structure_count'] += 1
        d['sorry_count'] += e.sorry_count

    domain_subdomains = defaultdict(set)
    for e in entries:
        if e.subdomain:
            domain_subdomains[e.domain].add(e.subdomain)

    domains = {}
    for domain in sorted(domain_files.keys()):
        d = domain_decls.get(domain, {})
        domains[domain] = {
            "display_name": domain,
            "parent_domain": None,
            "file_count": len(domain_files.get(domain, set())),
            "declaration_count": d.get('declaration_count', 0),
            "theorem_count": d.get('theorem_count', 0),
            "def_count": d.get('def_count', 0),
            "structure_count": d.get('structure_count', 0),
            "line_count": 0,
            "sorry_count": d.get('sorry_count', 0),
            "subdomains": sorted(domain_subdomains.get(domain, set())),
        }

    return domains


def build_bridge_index(root: Path, entries: list[CatalogEntry]) -> list:
    """Analyze bridge files and index their domain connections."""
    bridges_dir = root / 'Bridges'
    bridge_index = []

    domain_keywords = {
        'Tropical': ['tropical', 'max-plus', 'tropadd', 'tropmul', 'maslov', 'logsumexp'],
        'Algebra': ['algebra', 'division algebra', 'cayley-dickson', 'quaternion', 'octonion'],
        'Physics': ['quantum', 'relativity', 'spacetime', 'hamiltonian', 'bloch', 'photon'],
        'Pythagorean': ['pythagorean', 'berggren', 'triple', 'quadruple'],
        'InformationTheory': ['entropy', 'information', 'coding', 'channel', 'capacity'],
        'NumberTheory': ['modular form', 'langlands', 'zeta', 'riemann', 'lattice'],
        'MachineLearning': ['neural', 'relu', 'deep learning', 'transformer', 'softmax'],
        'Cryptography': ['encrypt', 'decrypt', 'zero-knowledge', 'hash', 'key'],
        'Topology': ['topology', 'homology', 'persistent', 'homotopy'],
        'CategoryTheory': ['category', 'functor', 'adjunction', 'natural transformation'],
        'Computation': ['factoring', 'oracle', 'algorithm', 'complexity'],
        'Geometry': ['stereographic', 'hyperbolic', 'spherical', 'geodesic'],
        'Logic': ['logic', 'computability', 'proof', 'decidability'],
        'EML': ['eml', 'emergent', 'spb', 'stereographic projection bridge'],
    }

    if not bridges_dir.exists():
        return bridge_index

    for bridge_file in sorted(bridges_dir.glob('*.lean')):
        rel_path = str(bridge_file.relative_to(root))
        try:
            content = bridge_file.read_text(encoding='utf-8')
        except Exception:
            continue

        content_lower = content.lower()
        connected = set()
        key_concepts = []

        for domain, keywords in domain_keywords.items():
            for kw in keywords:
                if kw in content_lower:
                    connected.add(domain)
                    key_concepts.append(kw)
                    break

        bridge_entries = [e for e in entries if e.source_file == f"Bridges/{bridge_file.name}"]
        theorem_count = sum(1 for e in bridge_entries if e.kind in ('theorem', 'lemma'))

        bridge_index.append({
            "bridge_file": f"Bridges/{bridge_file.name}",
            "domains_connected": sorted(connected),
            "key_concepts": sorted(set(key_concepts))[:10],
            "theorem_count": theorem_count,
        })

    return bridge_index


def file_fingerprints(catalog_root: str) -> dict:
    """Get modification times for all .lean files under catalog_root.

    Returns dict mapping relative_path -> mtime_iso string.
    """
    root = Path(catalog_root)
    fingerprints = {}
    for filepath in sorted(root.rglob('*.lean')):
        if 'tools' in filepath.parts:
            continue
        rel_path = str(filepath.relative_to(root))
        try:
            mtime = filepath.stat().st_mtime
            fingerprints[rel_path] = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(mtime))
        except OSError:
            continue
    return fingerprints


def diff_fingerprints(old_fingerprints: dict, new_fingerprints: dict) -> tuple:
    """Compare old and new file fingerprints.

    Returns (added, modified, removed, unchanged) as sets of rel_paths.
    """
    old_keys = set(old_fingerprints.keys())
    new_keys = set(new_fingerprints.keys())

    added = new_keys - old_keys
    removed = old_keys - new_keys
    common = old_keys & new_keys
    modified = {f for f in common if new_fingerprints[f] != old_fingerprints[f]}
    unchanged = {f for f in common if new_fingerprints[f] == old_fingerprints[f]}

    return added, modified, removed, unchanged


def scan_incremental(catalog_root: str, existing_db: dict, verbose: bool = False) -> dict:
    """Incrementally rescan: only parse new/modified files, merge with existing DB.

    Args:
        catalog_root: Path to Catalog/ directory
        existing_db: The existing catalog database dict (from catalog.json)
        verbose: Print progress

    Returns:
        Updated catalog database dict
    """
    root = Path(catalog_root)

    # Get current file fingerprints
    new_fingerprints = file_fingerprints(catalog_root)
    old_fingerprints = existing_db.get("metadata", {}).get("file_fingerprints", {})

    added, modified, removed, unchanged = diff_fingerprints(old_fingerprints, new_fingerprints)

    if verbose:
        print(f"Incremental scan: {len(added)} new, {len(modified)} modified, {len(removed)} removed, {len(unchanged)} unchanged")

    files_to_parse = added | modified

    # Parse new/modified files
    new_entries_by_file = {}
    new_imports_by_file = {}

    for filepath in sorted(root.rglob('*.lean')):
        if 'tools' in filepath.parts:
            continue
        rel_path = str(filepath.relative_to(root))
        if rel_path not in files_to_parse:
            continue
        try:
            content = filepath.read_text(encoding='utf-8')
        except Exception as e:
            if verbose:
                print(f"  WARNING: Could not read {rel_path}: {e}")
            continue

        parser = LeanFileParser(rel_path, content)
        entries = parser.parse()
        new_entries_by_file[rel_path] = entries
        new_imports_by_file[rel_path] = parser.imports

        if verbose and entries:
            print(f"  {rel_path}: {len(entries)} declarations (rescanned)")

    # Build merged entry list
    # Keep entries from unchanged files, replace entries from modified files, add new file entries
    existing_entries = existing_db.get("entries", [])
    kept_entries = []
    for e in existing_entries:
        sf = e.get("source_file", e.get("source_provenance", ""))
        if sf in removed:
            continue  # Remove entries from deleted files
        if sf in modified:
            continue  # Will be replaced by new parse
        if sf in added:
            continue  # Will be added from new parse
        kept_entries.append(e)

    # Convert kept entries back to CatalogEntry objects
    kept_catalog_entries = []
    for e in kept_entries:
        entry = CatalogEntry(
            id=e.get("id", ""),
            name=e.get("name", ""),
            qualified_name=e.get("qualified_name", ""),
            kind=e.get("kind", ""),
            namespace=e.get("namespace", ""),
            source_file=e.get("source_file", ""),
            module_path=e.get("module_path", ""),
            line_number=e.get("line_number", 0),
            end_line=e.get("end_line", 0),
            type_signature=e.get("type_signature", ""),
            doc_comment=e.get("doc_comment"),
            body=e.get("body", ""),
            domain=e.get("domain", ""),
            subdomain=e.get("subdomain"),
            imports=e.get("imports", []),
            internal_imports=e.get("internal_imports", []),
            proof_tactics=e.get("proof_tactics", []),
            sorry_count=e.get("sorry_count", 0),
            proof_length_lines=e.get("proof_length_lines", 0),
            is_noncomputable=e.get("is_noncomputable", False),
            canonical=e.get("canonical", True),
            duplicate_of=e.get("duplicate_of"),
            duplicate_group_id=e.get("duplicate_group_id"),
            source_provenance=e.get("source_provenance", ""),
        )
        kept_catalog_entries.append(entry)

    # Add new/modified file entries
    all_catalog_entries = kept_catalog_entries
    for rel_path, entries in new_entries_by_file.items():
        all_catalog_entries.extend(entries)

    # Merge imports
    all_imports = {}
    # Keep imports from existing entries for unchanged files
    for e in kept_entries:
        sf = e.get("source_file", e.get("source_provenance", ""))
        if sf not in all_imports:
            all_imports[sf] = e.get("imports", [])
    # Add new imports
    for rel_path, imports in new_imports_by_file.items():
        all_imports[rel_path] = imports

    # Collect lean file list (for stats and import graph)
    lean_files = sorted(root.rglob('*.lean'))
    lean_files = [f for f in lean_files if 'tools' not in f.parts]

    # Recompute everything
    all_entries = all_catalog_entries

    # Re-resolve duplicates
    all_entries, dup_groups = resolve_duplicates(all_entries)

    # Rebuild import graph
    import_graph = build_import_graph(lean_files, root, all_imports)

    # Rebuild domain stats
    domains = build_domain_stats(all_entries, lean_files, root)

    # Rebuild bridge index
    bridge_index = build_bridge_index(root, all_entries)

    # Compute metadata
    kind_counts = defaultdict(int)
    sorry_total = 0
    for e in all_entries:
        kind_counts[e.kind] += 1
        sorry_total += e.sorry_count

    file_count = len(new_fingerprints)

    metadata = {
        "schema_version": "1.0.0",
        "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "lean_version": "v4.28.0",
        "mathlib_version": "v4.28.0",
        "total_files": file_count,
        "total_declarations": len(all_entries),
        "total_theorems": kind_counts.get('theorem', 0) + kind_counts.get('lemma', 0),
        "total_defs": kind_counts.get('def', 0) + kind_counts.get('noncomputable_def', 0),
        "total_structures": (kind_counts.get('structure', 0) + kind_counts.get('class', 0)
                           + kind_counts.get('inductive', 0)),
        "total_lines": sum(e.proof_length_lines for e in all_entries),  # approximate
        "total_sorry": sorry_total,
        "total_duplicate_groups": len(dup_groups),
        "total_canonical": sum(1 for e in all_entries if e.canonical),
        "file_fingerprints": new_fingerprints,
    }

    catalog = {
        "metadata": metadata,
        "entries": [asdict(e) for e in all_entries],
        "domains": domains,
        "duplicate_groups": dup_groups,
        "import_graph": import_graph,
        "bridge_index": bridge_index,
    }

    return catalog


def main():
    parser = argparse.ArgumentParser(description="Extract Lean 4 declarations into catalog database")
    parser.add_argument("--source", required=True, help="Path to Catalog root directory")
    parser.add_argument("--output", required=True, help="Output JSON file path")
    parser.add_argument("--verbose", action="store_true", help="Print progress")
    args = parser.parse_args()

    start = time.time()
    catalog = scan_catalog(args.source, verbose=args.verbose)
    elapsed = time.time() - start

    catalog["metadata"]["extraction_duration_seconds"] = round(elapsed, 2)

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(catalog, f, indent=2, ensure_ascii=False)

    meta = catalog["metadata"]
    print(f"\nExtraction complete in {elapsed:.1f}s")
    print(f"  Files scanned:     {meta['total_files']}")
    print(f"  Declarations:      {meta['total_declarations']}")
    print(f"  Theorems/lemmas:    {meta['total_theorems']}")
    print(f"  Definitions:        {meta['total_defs']}")
    print(f"  Structures/classes: {meta['total_structures']}")
    print(f"  Duplicate groups:   {meta['total_duplicate_groups']}")
    print(f"  Canonical entries:  {meta['total_canonical']}")
    print(f"  sorry occurrences:  {meta['total_sorry']}")
    print(f"  Domains:            {len(catalog['domains'])}")
    print(f"  Bridge files:       {len(catalog['bridge_index'])}")
    print(f"\nOutput: {output_path}")


if __name__ == '__main__':
    main()