#!/usr/bin/env python3
"""Quick syntax and import check for the modified Aether files."""
import ast
import sys

files = [
    "catalog_analyzer.py",
    "pi_agent_client.py",
    "pi_orchestrator.py",
]

errors = []
for f in files:
    try:
        with open(f, "r") as fh:
            ast.parse(fh.read())
        print(f"✓ {f}: syntax OK")
    except SyntaxError as e:
        print(f"✗ {f}: SYNTAX ERROR at line {e.lineno}: {e.msg}")
        errors.append(f)

if errors:
    print(f"\n{len(errors)} file(s) have syntax errors!")
    sys.exit(1)
else:
    print(f"\nAll {len(files)} files pass syntax check.")

# Test imports
print("\n--- Import checks ---")
try:
    from catalog_analyzer import CatalogAnalyzer
    print("✓ CatalogAnalyzer imported")
    # Check new methods exist
    assert hasattr(CatalogAnalyzer, 'build_focused_context'), "Missing build_focused_context"
    assert hasattr(CatalogAnalyzer, 'collect_future_directions'), "Missing collect_future_directions"
    assert hasattr(CatalogAnalyzer, '_extract_section'), "Missing _extract_section"
    print("✓ New methods exist: build_focused_context, collect_future_directions, _extract_section")
except Exception as e:
    print(f"✗ CatalogAnalyzer import/check failed: {e}")
    errors.append("catalog_analyzer import")

try:
    from pathlib import Path
    analyzer = CatalogAnalyzer(Path("../Catalog"))
    analyzer.scan()
    
    # Test build_focused_context
    ctx = analyzer.build_focused_context("Tropical", "tropical certified robustness neural networks")
    print(f"✓ build_focused_context: {len(ctx)} chars")
    print(f"  Preview: {ctx[:200]}...")
    
    # Test collect_future_directions
    fd = analyzer.collect_future_directions(limit=2)
    print(f"✓ collect_future_directions: {len(fd)} chars")
    print(f"  Preview: {fd[:200]}...")
    
except Exception as e:
    print(f"✗ CatalogAnalyzer functional test failed: {e}")
    import traceback
    traceback.print_exc()
    errors.append("catalog_analyzer functional")

if errors:
    print(f"\n{len(errors)} check(s) failed!")
    sys.exit(1)
else:
    print("\nAll checks passed!")
