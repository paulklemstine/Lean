#!/usr/bin/env python3
"""Lightweight SQLite-backed theorem index for the Aether catalog.

Provides fast lookups of existing theorems by name, domain, and statement
text. Used for novelty detection, duplicate prevention, and cross-domain
connection discovery.
"""

from __future__ import annotations

import hashlib
import json
import re
import sqlite3
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Set, Tuple


@dataclass
class TheoremEntry:
    name: str
    file_path: str
    domain: str
    statement_text: str
    statement_hash: str
    theorem_type: str  # theorem, lemma, example, etc.
    quality_score: Optional[float] = None
    created_at: Optional[float] = None
    job_id: str = ""
    is_sorry: bool = False


class TheoremDatabase:
    """SQLite index of all theorems in the catalog.

    Lazily rebuilds from the catalog files when the database is stale or
    missing. After that, all lookups are O(1) SQL queries.
    """

    def __init__(self, db_path: Path, catalog_root: Path, *, rebuild_if_stale: bool = True):
        self.db_path = Path(db_path)
        self.catalog_root = Path(catalog_root)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._conn: Optional[sqlite3.Connection] = None
        self._init_db()
        if rebuild_if_stale:
            self.rebuild_if_needed()

    def _connect(self) -> sqlite3.Connection:
        if self._conn is None:
            self._conn = sqlite3.connect(str(self.db_path), check_same_thread=False)
            self._conn.row_factory = sqlite3.Row
        return self._conn

    def _init_db(self) -> None:
        conn = self._connect()
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS theorems (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                file_path TEXT NOT NULL,
                domain TEXT,
                statement_text TEXT,
                statement_hash TEXT NOT NULL,
                theorem_type TEXT,
                quality_score REAL,
                created_at REAL,
                job_id TEXT,
                is_sorry INTEGER DEFAULT 0
            );
            CREATE INDEX IF NOT EXISTS idx_name ON theorems(name);
            CREATE INDEX IF NOT EXISTS idx_hash ON theorems(statement_hash);
            CREATE INDEX IF NOT EXISTS idx_domain ON theorems(domain);
            CREATE INDEX IF NOT EXISTS idx_path ON theorems(file_path);

            CREATE TABLE IF NOT EXISTS metadata (
                key TEXT PRIMARY KEY,
                value TEXT
            );
            """
        )
        conn.commit()

    def _catalog_mtime(self) -> float:
        """Return the most recent mtime among all .lean files in the catalog."""
        max_mtime = 0.0
        if not self.catalog_root.exists():
            return 0.0
        for f in self.catalog_root.rglob("*.lean"):
            try:
                max_mtime = max(max_mtime, f.stat().st_mtime)
            except Exception:
                pass
        return max_mtime

    def _last_rebuild(self) -> float:
        conn = self._connect()
        row = conn.execute(
            "SELECT value FROM metadata WHERE key='last_rebuild'"
        ).fetchone()
        return float(row["value"]) if row else 0.0

    def _set_last_rebuild(self, t: float) -> None:
        conn = self._connect()
        conn.execute(
            "INSERT INTO metadata (key, value) VALUES ('last_rebuild', ?) "
            "ON CONFLICT(key) DO UPDATE SET value=excluded.value",
            (str(t),),
        )
        conn.commit()

    def rebuild_if_needed(self) -> None:
        catalog_mtime = self._catalog_mtime()
        last_rebuild = self._last_rebuild()
        # Rebuild if the catalog is newer than the db by more than 60 seconds,
        # or if the db is empty.
        conn = self._connect()
        count = conn.execute("SELECT COUNT(*) AS c FROM theorems").fetchone()["c"]
        if count == 0 or catalog_mtime > last_rebuild + 60:
            print(f"[TheoremDB] Rebuilding index from {count} theorems (catalog mtime={catalog_mtime:.0f}, db mtime={last_rebuild:.0f})")
            self.rebuild()

    def rebuild(self) -> None:
        """Full rebuild of the theorem index from catalog .lean files."""
        conn = self._connect()
        conn.execute("DELETE FROM theorems")
        if self.catalog_root.exists():
            entries = list(self._scan_catalog())
            self._insert_many(entries)
        self._set_last_rebuild(time.time())
        print(f"[TheoremDB] Indexed {self.count()} theorems from catalog")

    def _scan_catalog(self) -> Iterable[TheoremEntry]:
        """Yield TheoremEntry records from all .lean files in the catalog."""
        decl_pattern = re.compile(
            r"^(?:theorem|lemma|nonrec theorem|protected theorem|private theorem|example)\s+(\w+)",
            re.MULTILINE,
        )
        for f in self.catalog_root.rglob("*.lean"):
            try:
                text = f.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                continue
            rel_path = str(f.relative_to(self.catalog_root.parent))
            # Domain from path: Catalog/<Domain>/...
            parts = f.relative_to(self.catalog_root).parts
            domain = parts[0] if parts else "Unknown"
            for m in decl_pattern.finditer(text):
                name = m.group(1)
                start = m.end()
                # Capture a few lines of statement text for hashing/comparison
                statement = text[start : start + 400].strip()
                statement_hash = hashlib.sha256(statement.encode("utf-8")).hexdigest()[:32]
                is_sorry = "sorry" in statement.lower()
                theorem_type = "example" if m.group(0).startswith("example") else "lemma" if "lemma" in m.group(0).lower() else "theorem"
                yield TheoremEntry(
                    name=name,
                    file_path=rel_path,
                    domain=domain,
                    statement_text=statement[:500],
                    statement_hash=statement_hash,
                    theorem_type=theorem_type,
                    created_at=None,
                    job_id="",
                    is_sorry=is_sorry,
                )

    def _insert_many(self, entries: List[TheoremEntry]) -> None:
        if not entries:
            return
        conn = self._connect()
        conn.executemany(
            """
            INSERT INTO theorems
            (name, file_path, domain, statement_text, statement_hash, theorem_type,
             quality_score, created_at, job_id, is_sorry)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            [
                (
                    e.name,
                    e.file_path,
                    e.domain,
                    e.statement_text,
                    e.statement_hash,
                    e.theorem_type,
                    e.quality_score,
                    e.created_at,
                    e.job_id,
                    int(e.is_sorry),
                )
                for e in entries
            ],
        )
        conn.commit()

    def count(self) -> int:
        conn = self._connect()
        row = conn.execute("SELECT COUNT(*) AS c FROM theorems").fetchone()
        return row["c"]

    def contains_name(self, name: str) -> bool:
        conn = self._connect()
        row = conn.execute("SELECT 1 FROM theorems WHERE name = ? LIMIT 1", (name,)).fetchone()
        return row is not None

    def find_by_name(self, name: str) -> List[TheoremEntry]:
        conn = self._connect()
        rows = conn.execute(
            "SELECT * FROM theorems WHERE name = ?", (name,)
        ).fetchall()
        return [self._row_to_entry(r) for r in rows]

    def find_similar_names(self, prefix: str, limit: int = 10) -> List[str]:
        conn = self._connect()
        rows = conn.execute(
            "SELECT DISTINCT name FROM theorems WHERE name LIKE ? LIMIT ?",
            (f"%{prefix}%", limit),
        ).fetchall()
        return [r["name"] for r in rows]

    def find_by_domain(self, domain: str, limit: int = 100) -> List[TheoremEntry]:
        conn = self._connect()
        rows = conn.execute(
            "SELECT * FROM theorems WHERE domain = ? LIMIT ?", (domain, limit)
        ).fetchall()
        return [self._row_to_entry(r) for r in rows]

    def count_by_domain(self) -> Dict[str, int]:
        conn = self._connect()
        rows = conn.execute("SELECT domain, COUNT(*) AS c FROM theorems GROUP BY domain").fetchall()
        return {r["domain"]: r["c"] for r in rows}

    def add_cycle_theorems(self, job_id: str, domain: str, quality_score: float, lean_text: str) -> Dict[str, int]:
        """Add theorems from a newly completed cycle to the index.

        Returns novelty counts relative to the prior catalog state.
        """
        counts = {"new": 0, "strengthening": 0, "duplicate": 0, "disproof": 0, "unknown": 0}
        decl_pattern = re.compile(
            r"^(?:theorem|lemma|nonrec theorem|protected theorem|private theorem|example)\s+(\w+)",
            re.MULTILINE,
        )
        entries = []
        for m in decl_pattern.finditer(lean_text):
            name = m.group(1)
            start = m.end()
            statement = lean_text[start : start + 400].strip()
            statement_hash = hashlib.sha256(statement.encode("utf-8")).hexdigest()[:32]
            is_sorry = "sorry" in statement.lower()
            theorem_type = "example" if m.group(0).startswith("example") else "lemma" if "lemma" in m.group(0).lower() else "theorem"
            entries.append(
                TheoremEntry(
                    name=name,
                    file_path=f"cycle://{job_id}",
                    domain=domain,
                    statement_text=statement[:500],
                    statement_hash=statement_hash,
                    theorem_type=theorem_type,
                    quality_score=quality_score,
                    created_at=time.time(),
                    job_id=job_id,
                    is_sorry=is_sorry,
                )
            )

            # Classify novelty before inserting
            lower_stmt = statement.lower()
            is_disproof = any(
                kw in lower_stmt for kw in ("not exists", "no such", "false", "disprove", "counterexample")
            )
            if is_disproof:
                counts["disproof"] += 1
            elif self.contains_name(name):
                stronger_hints = any(kw in lower_stmt for kw in ("general", "stronger", "extends", "forall"))
                counts["strengthening" if stronger_hints else "duplicate"] += 1
            else:
                counts["new"] += 1

        if entries:
            self._insert_many(entries)
        return counts

    def _row_to_entry(self, row: sqlite3.Row) -> TheoremEntry:
        return TheoremEntry(
            name=row["name"],
            file_path=row["file_path"],
            domain=row["domain"],
            statement_text=row["statement_text"],
            statement_hash=row["statement_hash"],
            theorem_type=row["theorem_type"],
            quality_score=row["quality_score"],
            created_at=row["created_at"],
            job_id=row["job_id"],
            is_sorry=bool(row["is_sorry"]),
        )

    def close(self) -> None:
        if self._conn:
            self._conn.close()
            self._conn = None
