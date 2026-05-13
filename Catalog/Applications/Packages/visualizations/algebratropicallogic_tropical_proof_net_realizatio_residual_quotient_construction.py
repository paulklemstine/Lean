#!/usr/bin/env python3
"""Generate visualizations for the Tropical Proof-Net Realization Duality."""

import base64
import io
import json

def create_kernel_heatmap_svg(K, n, title="Entailment Kernel"):
    """Create an SVG heatmap of the kernel matrix."""
    INF = float('inf')
    cell_size = 60
    margin = 80
    w = margin + n * cell_size + 20
    h = margin + n * cell_size + 40

    # Find finite max for color scaling
    finite_vals = [K[i][j] for i in range(n) for j in range(n) if K[i][j] < INF]
    max_val = max(finite_vals) if finite_vals else 1

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">\n'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>\n'
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">{title}</text>\n'

    # Column headers
    for j in range(n):
        x = margin + j * cell_size + cell_size // 2
        svg += f'<text x="{x}" y="{margin - 10}" text-anchor="middle" font-size="13" fill="#555">q={j}</text>\n'

    # Row headers
    for i in range(n):
        y = margin + i * cell_size + cell_size // 2 + 5
        svg += f'<text x="{margin - 15}" y="{y}" text-anchor="end" font-size="13" fill="#555">p={i}</text>\n'

    for i in range(n):
        for j in range(n):
            x = margin + j * cell_size
            y = margin + i * cell_size
            val = K[i][j]

            if val == INF:
                color = "#2c3e50"
                text_color = "#ecf0f1"
                label = "∞"
            elif val == 0:
                color = "#27ae60"
                text_color = "white"
                label = "0"
            else:
                intensity = 1 - (val / max_val) * 0.7
                r = int(52 + (255 - 52) * intensity)
                g = int(152 + (255 - 152) * intensity)
                b = int(219 + (255 - 219) * intensity)
                color = f"rgb({r},{g},{b})"
                text_color = "#2c3e50" if intensity > 0.5 else "white"
                label = str(int(val))

            svg += f'<rect x="{x}" y="{y}" width="{cell_size}" height="{cell_size}" fill="{color}" stroke="#bdc3c7" stroke-width="1"/>\n'
            svg += f'<text x="{x + cell_size//2}" y="{y + cell_size//2 + 5}" text-anchor="middle" font-size="14" font-weight="bold" fill="{text_color}">{label}</text>\n'

    svg += '</svg>'
    return svg


def create_quotient_diagram_svg(classes, n):
    """Create an SVG diagram showing the quotient construction."""
    num_classes = len(classes)
    w = max(400, num_classes * 120 + 100)
    h = 250

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">\n'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>\n'
    svg += f'<text x="{w//2}" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Residual Quotient: {n} formulas → {num_classes} classes</text>\n'

    # Draw original formulas
    svg += f'<text x="30" y="70" font-size="12" fill="#777">Original:</text>\n'
    for i in range(n):
        x = 30 + i * 50
        svg += f'<circle cx="{x + 25}" cy="100" r="18" fill="#3498db" stroke="#2980b9" stroke-width="2"/>\n'
        svg += f'<text x="{x + 25}" y="105" text-anchor="middle" font-size="13" fill="white" font-weight="bold">{i}</text>\n'

    # Arrow
    svg += f'<text x="{w//2}" y="145" text-anchor="middle" font-size="20" fill="#e74c3c">↓ quotient</text>\n'

    # Draw classes
    svg += f'<text x="30" y="180" font-size="12" fill="#777">Quotient:</text>\n'
    class_list = list(classes.values())
    spacing = min(120, (w - 80) / max(num_classes, 1))
    for idx, members in enumerate(class_list):
        x = 40 + idx * spacing
        members_str = ",".join(str(m) for m in members)
        color = "#e74c3c" if len(members) > 1 else "#9b59b6"
        svg += f'<rect x="{x}" y="190" width="{spacing - 10}" height="40" rx="8" fill="{color}" stroke="#8e44ad" stroke-width="2"/>\n'
        svg += f'<text x="{x + (spacing-10)//2}" y="215" text-anchor="middle" font-size="12" fill="white" font-weight="bold">{{{members_str}}}</text>\n'

    svg += '</svg>'
    return svg


if __name__ == "__main__":
    from demo import (WeightedHornRule, WeightedConsequenceSystem)
    INF = float('inf')

    # Example 2: Linear chain
    rules2 = [
        WeightedHornRule({0}, 1, 2),
        WeightedHornRule({1}, 2, 3),
        WeightedHornRule({2}, 3, 5),
    ]
    sys2 = WeightedConsequenceSystem(4, rules2)
    K2 = sys2.entailment_kernel()
    svg_chain = create_kernel_heatmap_svg(K2, 4, "Entailment Kernel: Linear Chain")

    # Example 6: Bidirectional (compression)
    rules6 = [
        WeightedHornRule({0}, 1, 0),
        WeightedHornRule({1}, 0, 0),
        WeightedHornRule({2}, 3, 0),
        WeightedHornRule({3}, 2, 0),
        WeightedHornRule({0}, 2, 5),
    ]
    sys6 = WeightedConsequenceSystem(4, rules6)
    K6 = sys6.entailment_kernel()
    c6 = sys6.residual_classes(K6)
    svg_bidir = create_kernel_heatmap_svg(K6, 4, "Entailment Kernel: Bidirectional")
    svg_quotient = create_quotient_diagram_svg(c6, 4)

    # Save SVGs
    with open("kernel_chain.svg", "w") as f:
        f.write(svg_chain)
    with open("kernel_bidir.svg", "w") as f:
        f.write(svg_bidir)
    with open("quotient_bidir.svg", "w") as f:
        f.write(svg_quotient)

    print("Generated: kernel_chain.svg, kernel_bidir.svg, quotient_bidir.svg")
