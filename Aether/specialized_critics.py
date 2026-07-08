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
        """Run a single combined critic evaluation and return scores + rationale."""
        if self.pi_agent is None:
            return CriticScores(0.5, 0.5, 0.5, 0.5, rationale={
                "correctness": "No Pi-Agent", "novelty": "No Pi-Agent",
                "depth": "No Pi-Agent", "presentation": "No Pi-Agent"
            })

        system = (
            "You are a specialized mathematical critic. Evaluate the provided Lean 4 code across 4 dimensions, "
            "scoring each from 0.0 to 1.0:\n"
            "- correctness: 1.0 = complete, valid imports, no sorry/admit. 0.0 = broken or mostly placeholders.\n"
            "- novelty: 1.0 = genuinely new theorem/connection. 0.0 = trivial restatement or wrapper.\n"
            "- depth: 1.0 = deep proof, non-trivial tactics. 0.0 = trivial simp/rfl.\n"
            "- presentation: 1.0 = clear docs, structure, naming. 0.0 = opaque, missing docs.\n\n"
            "Respond ONLY with a valid JSON object in this exact format:\n"
            "{\n"
            '  "correctness": {"score": 0.0, "rationale": ""},\n'
            '  "novelty": {"score": 0.0, "rationale": ""},\n'
            '  "depth": {"score": 0.0, "rationale": ""},\n'
            '  "presentation": {"score": 0.0, "rationale": ""}\n'
            "}"
        )
        
        existing = ", ".join(sorted(existing_titles or set())[:20])
        user = (
            f"Concept: {concept_title}\n\n"
            f"Existing catalog theorem titles (sample): {existing}\n\n"
            f"Lean source to evaluate:\n```lean4\n{lean_source[:8000]}\n```"
        )
        
        try:
            raw = self.pi_agent._call_ollama(system, user, timeout=self.timeout)
            return self._parse_combined_scores(raw)
        except Exception as e:
            return CriticScores(0.5, 0.5, 0.5, 0.5, rationale={
                "correctness": f"Failed: {e}", "novelty": f"Failed: {e}",
                "depth": f"Failed: {e}", "presentation": f"Failed: {e}"
            })

    @staticmethod
    def _parse_combined_scores(raw: str) -> CriticScores:
        """Extract all 4 scores and rationales from the combined LLM output."""
        try:
            cleaned = raw.strip()
            if cleaned.startswith("```"):
                cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
                cleaned = re.sub(r"\s*```$", "", cleaned)
            data = json.loads(cleaned)
            
            if isinstance(data, dict):
                c_data = data.get("correctness", {})
                n_data = data.get("novelty", {})
                d_data = data.get("depth", {})
                p_data = data.get("presentation", {})
                
                return CriticScores(
                    correctness=max(0.0, min(1.0, float(c_data.get("score", 0.5)))),
                    novelty=max(0.0, min(1.0, float(n_data.get("score", 0.5)))),
                    depth=max(0.0, min(1.0, float(d_data.get("score", 0.5)))),
                    presentation=max(0.0, min(1.0, float(p_data.get("score", 0.5)))),
                    rationale={
                        "correctness": str(c_data.get("rationale", "")),
                        "novelty": str(n_data.get("rationale", "")),
                        "depth": str(d_data.get("rationale", "")),
                        "presentation": str(p_data.get("rationale", "")),
                    }
                )
        except Exception:
            pass
            
        return CriticScores(0.5, 0.5, 0.5, 0.5, rationale={
            "correctness": "Parse failed", "novelty": "Parse failed",
            "depth": "Parse failed", "presentation": "Parse failed"
        })
