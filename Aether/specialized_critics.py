#!/usr/bin/env python3
"""Specialized critics for Phase A quality assessment.

Each critic focuses on one axis of quality:
  - Correctness: does the Lean output compile and contain no sorry?
  - Novelty: is the result new relative to the catalog / Mathlib / literature?
  - Depth: is the proof non-trivial, insightful, and structurally complex?
  - Presentation: are theorem statements, docstrings, and naming clear?

The aggregate score applies a hard correctness gate and weights the other axes.
"""

import json
import re
from dataclasses import dataclass, field
from typing import Any, Dict, Optional


@dataclass
class CriticScores:
    correctness: float
    novelty: float
    depth: float
    presentation: float
    rationale: Dict[str, str] = field(default_factory=dict)

    def aggregate(self) -> float:
        """Return weighted aggregate score with a hard correctness gate."""
        if self.correctness < 1.0:
            return 0.0
        return (
            self.novelty * 0.35 +
            self.depth * 0.45 +
            self.presentation * 0.20
        )


class ThreadPromiseCritic:
    """Reviews the cumulative trajectory of a research thread.

    Unlike per-cycle critics, this critic reads the whole thread context and
    decides whether the thread is going somewhere (continue), needs a sharp
    pivot (pivot), or should be abandoned (terminate).
    """

    def __init__(self, pi_agent: Any, timeout: int = 180):
        self.pi_agent = pi_agent
        self.timeout = timeout

    def evaluate(
        self,
        thread: Any,
        cycle_quality_scores: Optional[list] = None,
    ) -> Dict[str, Any]:
        """Return {promise_score, recommendation, rationale} for a thread."""
        system = (
            "You are a senior research director reviewing a multi-cycle mathematical "
            "research thread. Score the thread's trajectory from 0 to 1 and recommend one of "
            "continue / pivot / terminate.\n\n"
            "- continue: the thread is producing genuine progress and should keep going.\n"
            "- pivot: the thread has stalled on the main conjecture and should change angle.\n"
            "- terminate: the thread is dead (repeating trivial results, contradictions resolved, "
            "or no path forward).\n\n"
            "Respond with valid JSON only: {\"promise_score\": float, \"recommendation\": string, "
            "\"rationale\": string}."
        )
        scores = cycle_quality_scores or getattr(thread, "cycle_quality_scores", [])
        context_lines = [
            f"Thread: {getattr(thread, 'thread_id', '')}",
            f"Root direction: {getattr(thread, 'root_direction_id', '')}",
            f"Cycles: {len(getattr(thread, 'cycles', []))}",
            f"Last progress cycle: {getattr(thread, 'last_progress_cycle', -1)}",
            f"Cycle quality scores: {scores}",
            f"Termination reason (if any): {getattr(thread, 'termination_reason', '')}",
        ]
        user = "\n".join(context_lines)

        if self.pi_agent is None:
            return {"promise_score": 0.5, "recommendation": "continue", "rationale": "No Pi-Agent available"}
        try:
            raw = self.pi_agent._call_ollama(system, user, timeout=self.timeout)
            return self._parse_thread_verdict(raw)
        except Exception as e:
            return {"promise_score": 0.5, "recommendation": "continue", "rationale": f"Thread promise critic failed: {e}"}

    @staticmethod
    def _parse_thread_verdict(raw: str) -> Dict[str, Any]:
        try:
            cleaned = raw.strip()
            if cleaned.startswith("```"):
                cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
                cleaned = re.sub(r"\s*```$", "", cleaned)
            data = json.loads(cleaned)
            if isinstance(data, dict):
                score = float(data.get("promise_score", 0.5))
                score = max(0.0, min(1.0, score))
                rec = str(data.get("recommendation", "continue")).lower()
                if rec not in ("continue", "pivot", "terminate"):
                    rec = "continue"
                rationale = str(data.get("rationale", ""))
                return {"promise_score": score, "recommendation": rec, "rationale": rationale}
        except Exception:
            pass

        # Fallback: keyword heuristics
        raw_lower = raw.lower()
        if "terminate" in raw_lower:
            return {"promise_score": 0.2, "recommendation": "terminate", "rationale": raw[:200]}
        if "pivot" in raw_lower:
            return {"promise_score": 0.5, "recommendation": "pivot", "rationale": raw[:200]}
        return {"promise_score": 0.6, "recommendation": "continue", "rationale": raw[:200]}


class SpecializedCritic:
    """Run four focused critics and aggregate their scores."""

    WEIGHTS = {"novelty": 0.35, "depth": 0.45, "presentation": 0.20}

    def __init__(self, pi_agent: Any, timeout: int = 120):
        self.pi_agent = pi_agent
        self.timeout = timeout

    def evaluate(
        self,
        lean_source: str,
        concept_title: str = "",
        concept_description: str = "",
        existing_titles: Optional[set] = None,
    ) -> CriticScores:
        """Run all four critics and return scores + rationale."""
        correctness = self._correctness(lean_source)
        novelty = self._novelty(lean_source, concept_title, existing_titles)
        depth = self._depth(lean_source, concept_title)
        presentation = self._presentation(lean_source, concept_title)

        return CriticScores(
            correctness=correctness["score"],
            novelty=novelty["score"],
            depth=depth["score"],
            presentation=presentation["score"],
            rationale={
                "correctness": correctness.get("rationale", ""),
                "novelty": novelty.get("rationale", ""),
                "depth": depth.get("rationale", ""),
                "presentation": presentation.get("rationale", ""),
            },
        )

    # ── Individual critics ──

    def _correctness(self, lean_source: str) -> Dict[str, Any]:
        system = (
            "You are a correctness critic for Lean 4 proofs. Score the output from 0 to 1 "
            "where 1 means the code is complete, compiles, has valid imports, and contains no "
            "`sorry`, `admit`, or placeholder proofs. 0 means it is broken or mostly placeholders. "
            "Respond with valid JSON only: {\"score\": float, \"rationale\": string}."
        )
        user = f"Lean source to evaluate:\n```lean4\n{lean_source[:8000]}\n```"
        return self._ask_critic(system, user)

    def _novelty(
        self, lean_source: str, concept_title: str, existing_titles: Optional[set]
    ) -> Dict[str, Any]:
        system = (
            "You are a novelty critic. Score how new/non-obvious the result is from 0 to 1. "
            "1 means a genuinely new theorem or connection; 0 means a trivial restatement, wrapper, "
            "or known result. Respond with valid JSON only: {\"score\": float, \"rationale\": string}."
        )
        existing = ", ".join(sorted(existing_titles or set())[:20])
        user = (
            f"Concept: {concept_title}\n\n"
            f"Existing catalog theorem titles (sample): {existing}\n\n"
            f"Lean source:\n```lean4\n{lean_source[:8000]}\n```"
        )
        return self._ask_critic(system, user)

    def _depth(self, lean_source: str, concept_title: str) -> Dict[str, Any]:
        system = (
            "You are a depth critic. Score proof/theorem depth from 0 to 1. "
            "1 means a deep, insightful proof with non-trivial tactics, new definitions, and "
            "cross-domain connections; 0 means trivial `simp`/`rfl` proofs or definitional equalities. "
            "Respond with valid JSON only: {\"score\": float, \"rationale\": string}."
        )
        user = (
            f"Concept: {concept_title}\n\n"
            f"Lean source:\n```lean4\n{lean_source[:8000]}\n```"
        )
        return self._ask_critic(system, user)

    def _presentation(self, lean_source: str, concept_title: str) -> Dict[str, Any]:
        system = (
            "You are a presentation critic. Score clarity from 0 to 1. "
            "1 means clear theorem statements, helpful doc comments, good naming, and readable structure; "
            "0 means opaque names, missing docs, or confusing organization. "
            "Respond with valid JSON only: {\"score\": float, \"rationale\": string}."
        )
        user = (
            f"Concept: {concept_title}\n\n"
            f"Lean source:\n```lean4\n{lean_source[:8000]}\n```"
        )
        return self._ask_critic(system, user)

    # ── Shared machinery ──

    def _ask_critic(self, system: str, user: str) -> Dict[str, Any]:
        """Call the Pi-Agent and parse a {score, rationale} JSON response."""
        if self.pi_agent is None:
            return {"score": 0.5, "rationale": "No Pi-Agent available"}
        try:
            raw = self.pi_agent._call_ollama(system, user, timeout=self.timeout)
            return self._parse_score(raw)
        except Exception as e:
            return {"score": 0.5, "rationale": f"Critic call failed: {e}"}

    @staticmethod
    def _parse_score(raw: str) -> Dict[str, Any]:
        """Extract a {score, rationale} dict from raw LLM output."""
        # Try to find a JSON object in the response
        try:
            # Strip markdown fences if present
            cleaned = raw.strip()
            if cleaned.startswith("```"):
                cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
                cleaned = re.sub(r"\s*```$", "", cleaned)
            data = json.loads(cleaned)
            if isinstance(data, dict):
                score = float(data.get("score", 0.5))
                score = max(0.0, min(1.0, score))
                rationale = str(data.get("rationale", ""))
                return {"score": score, "rationale": rationale}
        except Exception:
            pass

        # Fallback: regex for a decimal between 0 and 1
        match = re.search(r"(0\.\d+|1\.0|1)", raw)
        if match:
            return {"score": max(0.0, min(1.0, float(match.group(1)))), "rationale": raw[:200]}
        return {"score": 0.5, "rationale": raw[:200]}
