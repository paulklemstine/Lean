#!/usr/bin/env python3
"""ArchiveManager: durable, content-addressable archive of Aristotle projects.

Stores every file from every Aristotle input/output archive exactly once,
using SHA-256 content addressing for deduplication. Maintains a SQLite master
catalog of projects, files, theorems, and prompts.

Usage:
    am = ArchiveManager(Path("Archive"))
    manifest = am.archive_project(
        project_id="abc123",
        input_dir=Path("/tmp/project_input"),
        output_dir=Path("/tmp/project_output"),
        description="",
        status="RUNNING",
        created_at=iso,
        last_updated=iso,
    )
"""

import hashlib
import json
import os
import re
import sqlite3
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import tarfile


@dataclass
class ProjectManifest:
    """Manifest summarizing one Aristotle project archive."""
    project_id: str
    description: str
    status: str
    created_at: str
    last_updated: str
    input_files: List[Dict]
    output_files: List[Dict]
    prompt_hash: Optional[str]
    main_lean_hash: Optional[str]


class ArchiveManager:
    """Content-addressable archive manager with SQLite master catalog."""

    def __init__(self, archive_root: Path):
        self.archive_root = Path(archive_root)
        self.blobs_dir = self.archive_root / "blobs"
        self.manifests_dir = self.archive_root / "manifests"
        self.db_path = self.archive_root / "catalog.sqlite"

        self.archive_root.mkdir(parents=True, exist_ok=True)
        self.blobs_dir.mkdir(parents=True, exist_ok=True)
        self.manifests_dir.mkdir(parents=True, exist_ok=True)

        self._conn: Optional[sqlite3.Connection] = None
        self._theorem_cache: set = set()
        self._init_db()

    def _connect(self) -> sqlite3.Connection:
        if self._conn is None:
            self._conn = sqlite3.connect(str(self.db_path), check_same_thread=False)
            self._conn.row_factory = sqlite3.Row
            # WAL mode + relaxed sync for bulk ingestion speed
            self._conn.execute("PRAGMA journal_mode=WAL")
            self._conn.execute("PRAGMA synchronous=NORMAL")
            self._conn.execute("PRAGMA temp_store=MEMORY")
        return self._conn

    def _init_db(self) -> None:
        conn = self._connect()
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS files (
                hash TEXT PRIMARY KEY,
                size INTEGER NOT NULL,
                content_type TEXT,
                first_seen_at REAL NOT NULL
            );

            CREATE TABLE IF NOT EXISTS projects (
                project_id TEXT PRIMARY KEY,
                description TEXT,
                status TEXT,
                created_at TEXT,
                last_updated TEXT,
                prompt_hash TEXT,
                main_lean_hash TEXT,
                manifest_path TEXT,
                archived_at REAL NOT NULL
            );

            CREATE TABLE IF NOT EXISTS project_files (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                project_id TEXT NOT NULL,
                file_hash TEXT NOT NULL,
                path_inside_archive TEXT NOT NULL,
                role TEXT NOT NULL,
                FOREIGN KEY (project_id) REFERENCES projects(project_id),
                FOREIGN KEY (file_hash) REFERENCES files(hash)
            );
            CREATE INDEX IF NOT EXISTS idx_project_files_project ON project_files(project_id);
            CREATE INDEX IF NOT EXISTS idx_project_files_hash ON project_files(file_hash);

            CREATE TABLE IF NOT EXISTS theorems (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                file_hash TEXT NOT NULL,
                project_id TEXT,
                domain TEXT,
                statement_text TEXT,
                full_statement TEXT,
                proof_text TEXT,
                docstring TEXT,
                line_number INTEGER,
                file_path TEXT,
                theorem_type TEXT,
                declaration_kind TEXT,
                is_sorry INTEGER DEFAULT 0,
                uses_sorry INTEGER DEFAULT 0,
                is_complete INTEGER DEFAULT 0,
                parameters TEXT,
                return_type TEXT,
                metadata_json TEXT,
                FOREIGN KEY (file_hash) REFERENCES files(hash),
                FOREIGN KEY (project_id) REFERENCES projects(project_id),
                UNIQUE(name, file_hash)
            );
            CREATE INDEX IF NOT EXISTS idx_theorems_name ON theorems(name);
            CREATE INDEX IF NOT EXISTS idx_theorems_hash ON theorems(file_hash);
            CREATE INDEX IF NOT EXISTS idx_theorems_domain ON theorems(domain);
            CREATE INDEX IF NOT EXISTS idx_theorems_project ON theorems(project_id);

            CREATE TABLE IF NOT EXISTS prompts (
                project_id TEXT PRIMARY KEY,
                prompt_hash TEXT NOT NULL,
                prompt_version TEXT,
                length INTEGER NOT NULL,
                FOREIGN KEY (project_id) REFERENCES projects(project_id),
                FOREIGN KEY (prompt_hash) REFERENCES files(hash)
            );

            CREATE TABLE IF NOT EXISTS packages (
                project_id TEXT PRIMARY KEY,
                package_hash TEXT NOT NULL,
                title TEXT,
                domain TEXT,
                description TEXT,
                exp_id TEXT,
                date TEXT,
                key_results_json TEXT,
                keywords_json TEXT,
                lean_files_json TEXT,
                article_hash TEXT,
                research_paper_hash TEXT,
                future_directions_hash TEXT,
                json_payload TEXT NOT NULL,
                FOREIGN KEY (project_id) REFERENCES projects(project_id),
                FOREIGN KEY (package_hash) REFERENCES files(hash)
            );
            CREATE INDEX IF NOT EXISTS idx_packages_domain ON packages(domain);
            """
        )
        self._migrate_theorems_columns()
        conn.commit()

    def _migrate_theorems_columns(self) -> None:
        """Add columns added after initial schema creation."""
        conn = self._connect()
        cursor = conn.execute("PRAGMA table_info(theorems)")
        existing = {row["name"] for row in cursor.fetchall()}
        new_columns = [
            ("project_id", "TEXT"),
            ("full_statement", "TEXT"),
            ("proof_text", "TEXT"),
            ("docstring", "TEXT"),
            ("line_number", "INTEGER"),
            ("file_path", "TEXT"),
            ("declaration_kind", "TEXT"),
            ("uses_sorry", "INTEGER DEFAULT 0"),
            ("is_complete", "INTEGER DEFAULT 0"),
            ("parameters", "TEXT"),
            ("return_type", "TEXT"),
            ("metadata_json", "TEXT"),
        ]
        for col, dtype in new_columns:
            if col not in existing:
                conn.execute(f"ALTER TABLE theorems ADD COLUMN {col} {dtype}")

    def _blob_path(self, file_hash: str) -> Path:
        """Map a SHA-256 hash to a 4-level sharded blob path."""
        return self.blobs_dir / file_hash[0:2] / file_hash[2:4] / file_hash

    def store_file(self, data: bytes, content_type: str = "application/octet-stream") -> str:
        """Store bytes in CAS and return the SHA-256 hash."""
        file_hash = hashlib.sha256(data).hexdigest()
        blob_path = self._blob_path(file_hash)
        if not blob_path.exists():
            blob_path.parent.mkdir(parents=True, exist_ok=True)
            blob_path.write_bytes(data)
            conn = self._connect()
            conn.execute(
                "INSERT OR IGNORE INTO files (hash, size, content_type, first_seen_at) VALUES (?, ?, ?, ?)",
                (file_hash, len(data), content_type, time.time()),
            )
            conn.commit()
        return file_hash

    def read_file(self, file_hash: str) -> Optional[bytes]:
        """Read bytes from CAS by hash."""
        blob_path = self._blob_path(file_hash)
        if blob_path.exists():
            return blob_path.read_bytes()
        return None

    def file_exists(self, file_hash: str) -> bool:
        return self._blob_path(file_hash).exists()

    def _scan_theorems(self, file_hash: str, content: str, domain: str) -> List[Dict]:
        """Extract theorem/lemma/example declarations from Lean content."""
        decl_pattern = re.compile(
            r"^(?:theorem|lemma|nonrec theorem|protected theorem|private theorem|example)\s+(\w+)",
            re.MULTILINE,
        )
        theorems = []
        for m in decl_pattern.finditer(content):
            name = m.group(1)
            key = (name, file_hash)
            if key in self._theorem_cache:
                continue
            self._theorem_cache.add(key)
            start = m.end()
            statement = content[start : start + 200].strip()
            is_sorry = "sorry" in statement.lower()
            theorem_type = (
                "example" if m.group(0).startswith("example")
                else "lemma" if "lemma" in m.group(0).lower()
                else "theorem"
            )
            theorems.append({
                "name": name,
                "file_hash": file_hash,
                "domain": domain,
                "statement_text": statement[:200],
                "theorem_type": theorem_type,
                "is_sorry": is_sorry,
            })
        return theorems

    def _extract_domain_from_path(self, rel_path: str) -> str:
        """Infer catalog domain from a relative path like 'Catalog/Algebra/Foo.lean'."""
        parts = Path(rel_path).parts
        if len(parts) >= 2 and parts[0].lower() in ("catalog",):
            return parts[1]
        if parts:
            return parts[0]
        return "Unknown"

    def _archive_directory(
        self,
        directory: Path,
        role: str,
        skip_input_catalog_context: bool = True,
    ) -> Tuple[List[Dict], Optional[str], Optional[str], List[Dict]]:
        """Archive all files in a directory tree.

        Returns (file records, prompt_hash, main_lean_hash, new_theorems).
        """
        files: List[Dict] = []
        prompt_hash: Optional[str] = None
        main_lean_hash: Optional[str] = None
        theorems: List[Dict] = []

        if not directory.exists():
            return files, prompt_hash, main_lean_hash, theorems

        for src in sorted(directory.rglob("*")):
            if not src.is_file():
                continue
            rel = src.relative_to(directory)
            rel_str = str(rel).replace("\\", "/")

            # Skip compiled artifacts and build caches
            if any(part in (".lake", "build", "lake-packages", "__pycache__") for part in rel.parts):
                continue
            if rel_str.endswith(".olean") or rel_str.endswith(".ilean"):
                continue

            # For inputs, skip the full Catalog/ context tree — it is already
            # stored in the live Catalog directory and deduplicated there. We
            # still archive the unique files (PROMPT.md, Main.lean, configs).
            if role == "input" and skip_input_catalog_context and rel_str.startswith("Catalog/"):
                continue

            data = src.read_bytes()
            content_type = "text/plain"
            if rel_str.endswith(".lean"):
                content_type = "text/x-lean"
            elif rel_str.endswith(".md"):
                content_type = "text/markdown"
            elif rel_str.endswith(".tar.gz"):
                content_type = "application/gzip"
            elif rel_str.endswith(".json"):
                content_type = "application/json"

            file_hash = hashlib.sha256(data).hexdigest()
            is_new_file = not self.file_exists(file_hash)
            self.store_file(data, content_type=content_type)
            record = {
                "hash": file_hash,
                "path": rel_str,
                "size": len(data),
                "role": role,
            }
            files.append(record)

            if role in ("input",) and rel_str.endswith("PROMPT.md"):
                prompt_hash = file_hash
            if rel_str.endswith("Main.lean") and not main_lean_hash:
                main_lean_hash = file_hash

            # Only scan theorems for newly-seen lean files to save time
            if rel_str.endswith(".lean") and is_new_file:
                try:
                    text = data.decode("utf-8", errors="replace")
                except Exception:
                    text = ""
                domain = self._extract_domain_from_path(rel_str)
                theorems.extend(self._scan_theorems(file_hash, text, domain))

        return files, prompt_hash, main_lean_hash, theorems

    def archive_project(
        self,
        project_id: str,
        description: str,
        status: str,
        created_at: str,
        last_updated: str,
        input_dir: Optional[Path] = None,
        output_dir: Optional[Path] = None,
        input_archive_path: Optional[Path] = None,
        output_archive_path: Optional[Path] = None,
        skip_input_catalog_context: bool = True,
    ) -> ProjectManifest:
        """Archive a project from extracted directories and/or tar.gz archives."""
        if input_archive_path and input_archive_path.exists():
            input_dir = self._extract_tar(input_archive_path)
        if output_archive_path and output_archive_path.exists():
            output_dir = self._extract_tar(output_archive_path)

        input_files, prompt_hash, main_lean_hash, input_theorems = self._archive_directory(
            input_dir or Path("/nonexistent"), "input", skip_input_catalog_context=skip_input_catalog_context
        )
        output_files, _, _, output_theorems = self._archive_directory(
            output_dir or Path("/nonexistent"), "output"
        )
        all_theorems = input_theorems + output_theorems

        # Detect prompt version from prompt text
        prompt_version: Optional[str] = None
        if prompt_hash:
            prompt_text = self.read_file(prompt_hash)
            if prompt_text:
                text = prompt_text.decode("utf-8", errors="replace")
                m = re.search(r"Phase A Research Mission (v\d+[a-z]?):", text)
                if m:
                    prompt_version = m.group(1)
                elif "v15" in text and "MATHEMATICAL RESEARCH MISSION" in text:
                    prompt_version = "v15"

        manifest = ProjectManifest(
            project_id=project_id,
            description=description,
            status=status,
            created_at=created_at,
            last_updated=last_updated,
            input_files=input_files,
            output_files=output_files,
            prompt_hash=prompt_hash,
            main_lean_hash=main_lean_hash,
        )

        manifest_path = self.manifests_dir / f"{project_id}.json"
        manifest_path.write_text(
            json.dumps({
                "project_id": manifest.project_id,
                "description": manifest.description,
                "status": manifest.status,
                "created_at": manifest.created_at,
                "last_updated": manifest.last_updated,
                "prompt_hash": manifest.prompt_hash,
                "main_lean_hash": manifest.main_lean_hash,
                "input_files": manifest.input_files,
                "output_files": manifest.output_files,
            }, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

        conn = self._connect()
        conn.execute(
            "INSERT OR REPLACE INTO projects "
            "(project_id, description, status, created_at, last_updated, prompt_hash, main_lean_hash, manifest_path, archived_at) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
            (
                project_id,
                description,
                status,
                created_at,
                last_updated,
                prompt_hash,
                main_lean_hash,
                str(manifest_path.relative_to(self.archive_root)),
                time.time(),
            ),
        )
        all_files = input_files + output_files
        conn.executemany(
            "INSERT OR IGNORE INTO project_files (project_id, file_hash, path_inside_archive, role) "
            "VALUES (?, ?, ?, ?)",
            [
                (project_id, f["hash"], f["path"], f["role"])
                for f in all_files
            ],
        )

        # Batch insert new theorems (deduped by unique(name, file_hash))
        if all_theorems:
            conn.executemany(
                "INSERT OR IGNORE INTO theorems "
                "(name, file_hash, project_id, domain, statement_text, full_statement, "
                "proof_text, docstring, line_number, file_path, theorem_type, declaration_kind, "
                "is_sorry, uses_sorry, is_complete, parameters, return_type, metadata_json) "
                "VALUES (:name, :file_hash, :project_id, :domain, :statement_text, :full_statement, "
                ":proof_text, :docstring, :line_number, :file_path, :theorem_type, :declaration_kind, "
                ":is_sorry, :uses_sorry, :is_complete, :parameters, :return_type, :metadata_json)",
                all_theorems,
            )

        if prompt_hash:
            conn.execute(
                "INSERT OR REPLACE INTO prompts (project_id, prompt_hash, prompt_version, length) "
                "VALUES (?, ?, ?, ?)",
                (
                    project_id,
                    prompt_hash,
                    prompt_version,
                    len(self.read_file(prompt_hash) or b""),
                ),
            )
        conn.commit()
        return manifest

    def _extract_tar(self, tar_path: Path) -> Path:
        """Extract a tar.gz to a temp dir and return that dir."""
        tmpdir = Path(tempfile.mkdtemp(prefix=f"aristotle_archive_{tar_path.stem}_"))
        with tarfile.open(tar_path, "r:gz") as tar:
            tar.extractall(path=tmpdir)
        return tmpdir

    def project_exists(self, project_id: str) -> bool:
        conn = self._connect()
        row = conn.execute("SELECT 1 FROM projects WHERE project_id=?", (project_id,)).fetchone()
        return row is not None

    def project_has_output(self, project_id: str) -> bool:
        conn = self._connect()
        row = conn.execute(
            "SELECT 1 FROM project_files WHERE project_id=? AND role='output' LIMIT 1",
            (project_id,),
        ).fetchone()
        return row is not None

    def store_package(
        self,
        project_id: str,
        package_json: str,
        article_hash: Optional[str] = None,
        research_paper_hash: Optional[str] = None,
        future_directions_hash: Optional[str] = None,
    ) -> str:
        """Store a research JSON package in CAS and the packages table.

        Returns the SHA-256 hash of the canonical package JSON.
        """
        canonical = json.dumps(
            json.loads(package_json),
            indent=None,
            ensure_ascii=False,
            sort_keys=True,
        )
        package_hash = self.store_file(canonical.encode("utf-8"), content_type="application/json")
        pkg = json.loads(canonical)

        def _hash_field(field_name: str) -> Optional[str]:
            value = pkg.get(field_name)
            if isinstance(value, str) and len(value) > 0:
                return self.store_file(value.encode("utf-8"), content_type="text/markdown")
            return None

        article_hash = article_hash or _hash_field("article")
        research_paper_hash = research_paper_hash or _hash_field("research_paper")
        future_directions_hash = future_directions_hash or _hash_field("future_directions")

        conn = self._connect()
        conn.execute(
            "INSERT OR REPLACE INTO packages "
            "(project_id, package_hash, title, domain, description, exp_id, date, "
            "key_results_json, keywords_json, lean_files_json, article_hash, "
            "research_paper_hash, future_directions_hash, json_payload) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            (
                project_id,
                package_hash,
                pkg.get("title"),
                pkg.get("domain"),
                pkg.get("description"),
                pkg.get("exp_id"),
                pkg.get("date"),
                json.dumps(pkg.get("key_results") or [], ensure_ascii=False),
                json.dumps(pkg.get("keywords") or [], ensure_ascii=False),
                json.dumps(pkg.get("lean_files") or [], ensure_ascii=False),
                article_hash,
                research_paper_hash,
                future_directions_hash,
                canonical,
            ),
        )
        conn.commit()
        return package_hash

    def get_package(self, project_id: str) -> Optional[Dict]:
        """Load a stored package by project_id."""
        conn = self._connect()
        row = conn.execute(
            "SELECT json_payload FROM packages WHERE project_id=?", (project_id,)
        ).fetchone()
        if not row:
            return None
        try:
            return json.loads(row["json_payload"])
        except Exception:
            return None

    def get_project_theorems(self, project_id: str) -> List[Dict]:
        """Return all theorem records associated with a project."""
        conn = self._connect()
        rows = conn.execute(
            "SELECT * FROM theorems WHERE project_id=?", (project_id,)
        ).fetchall()
        return [dict(r) for r in rows]

    def get_stats(self) -> Dict:
        conn = self._connect()
        stats = {}
        for table in ("projects", "files", "project_files", "theorems", "prompts", "packages"):
            row = conn.execute(f"SELECT COUNT(*) AS c FROM {table}").fetchone()
            stats[table] = row["c"]
        size_bytes = sum(
            f.stat().st_size for f in self.blobs_dir.rglob("*") if f.is_file()
        )
        stats["blobs_size_bytes"] = size_bytes
        stats["blobs_size_mb"] = round(size_bytes / (1024 * 1024), 2)
        return stats
