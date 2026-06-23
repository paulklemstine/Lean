"""Tests for Phase 4 rules-first pruning predicate (Lever F)."""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent.parent))


def _dir(title="t", description="d", priority=0.5, domains=None, source_path="exp:1"):
    from research_memory import FutureDirection
    return FutureDirection(
        id="d1", title=title, description=description, source_exp_id="s",
        source_path=source_path, domains=domains or [], priority_score=priority,
    )


def test_rule_prunes_low_quality_junk():
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="Junk", description="Junk", priority=0.2)  # desc == title, low pri
    assert KnowledgeExtractor._rule_prunable(d, 0.10) is True


def test_rule_prunes_empty_description():
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="Whatever", description="", priority=0.3)
    assert KnowledgeExtractor._rule_prunable(d, 0.05) is True


def test_rule_prunes_short_description():
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="Short", description="hi", priority=0.3)  # <15 chars
    assert KnowledgeExtractor._rule_prunable(d, 0.10) is True


def test_rule_keeps_substantive_description():
    """A real description (>15 chars, != title) is kept even at low quality."""
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="Conjecture X", description="A falsifiable conjecture about primes with a clear test.",
             priority=0.3)
    assert KnowledgeExtractor._rule_prunable(d, 0.10) is False


def test_rule_keeps_high_quality():
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="X", description="", priority=0.3)
    assert KnowledgeExtractor._rule_prunable(d, 0.50) is False  # score >= 0.20


def test_rule_protects_novelty():
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="Junk", description="Junk", priority=0.2, domains=["Novelty"])
    assert KnowledgeExtractor._rule_prunable(d, 0.05) is False


def test_rule_protects_seed():
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="Junk", description="Junk", priority=0.2, source_path="seed:foo")
    assert KnowledgeExtractor._rule_prunable(d, 0.05) is False


def test_rule_protects_high_priority():
    from knowledge_extractor import KnowledgeExtractor
    d = _dir(title="Junk", description="Junk", priority=0.85)
    assert KnowledgeExtractor._rule_prunable(d, 0.05) is False