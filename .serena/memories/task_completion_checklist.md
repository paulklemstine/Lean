# Task Completion Checklist

When a coding task is completed, verify:

1. **Build check**: Run `lake build <target>` (or `lake build Catalog` for full build) to ensure no compilation errors
2. **Format check**: Run `lake fmt` to ensure code is properly formatted (optional but recommended)
3. **Import check**: Ensure all new imports use `Catalog.*` module paths (not old directory structure paths)
4. **Type check**: Lean's type checker runs as part of `lake build` — no separate step needed
5. **No duplicate declarations**: Check that new declarations don't clash with existing ones (see DECLARATION_INDEX.md)

Note: Full `lake build Catalog` can be very slow for this large project. Prefer building specific targets when possible.