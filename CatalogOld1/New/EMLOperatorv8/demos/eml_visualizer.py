#!/usr/bin/env python3
"""
EML Visualizer — Generate SVG visualizations of EML operator properties.

Generates publication-quality SVG diagrams:
1. EML level set contours
2. Diagonal map orbit diagram
3. E-tower growth chart
4. Fixed point cobweb convergence
5. AM-GM bridge curve
6. EML operator connection overview
"""

import math
import os

def eml(x, y):
    if y <= 0: return float('inf')
    return math.exp(x) - math.log(y)

def svg_header(w, h, title):
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">
  <defs>
    <style>
      .title {{ font: bold 18px 'Helvetica Neue', Arial, sans-serif; fill: #2c3e50; }}
      .label {{ font: 13px 'Helvetica Neue', Arial, sans-serif; fill: #555; }}
      .axis-label {{ font: bold 14px 'Helvetica Neue', Arial, sans-serif; fill: #333; }}
      .tick {{ font: 11px monospace; fill: #777; }}
      .annotation {{ font: italic 12px 'Georgia', serif; fill: #c0392b; }}
    </style>
  </defs>
  <rect width="{w}" height="{h}" fill="white" rx="8"/>
  <text x="{w//2}" y="30" text-anchor="middle" class="title">{title}</text>
'''

def generate_level_sets():
    W, H = 700, 500
    s = svg_header(W, H, "EML Level Sets: exp(x) − ln(y) = c")
    px, py, pw, ph = 80, 55, 560, 390
    s += f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="#fafafa" stroke="#ddd"/>\n'
    xr, yr = (-2, 3), (0.05, 8)
    def sx(x): return px + (x - xr[0]) / (xr[1] - xr[0]) * pw
    def sy(y): return py + ph - (y - yr[0]) / (yr[1] - yr[0]) * ph
    for xv in range(-2, 4):
        s += f'<line x1="{sx(xv):.0f}" y1="{py}" x2="{sx(xv):.0f}" y2="{py+ph}" stroke="#eee"/>\n'
        s += f'<text x="{sx(xv):.0f}" y="{py+ph+15}" text-anchor="middle" class="tick">{xv}</text>\n'
    for yv in [1,2,3,4,5,6,7]:
        s += f'<line x1="{px}" y1="{sy(yv):.0f}" x2="{px+pw}" y2="{sy(yv):.0f}" stroke="#eee"/>\n'
        s += f'<text x="{px-8}" y="{sy(yv)+4:.0f}" text-anchor="end" class="tick">{yv}</text>\n'
    colors = ['#e74c3c','#e67e22','#f1c40f','#2ecc71','#3498db','#9b59b6','#1abc9c','#34495e']
    for c, col in zip([-1,0,1,2,3,4,5,6], colors):
        pts = []
        for i in range(300):
            x = xr[0] + (xr[1]-xr[0])*i/299
            y = math.exp(math.exp(x)-c)
            if yr[0]<=y<=yr[1]: pts.append(f"{sx(x):.1f},{sy(y):.1f}")
        if len(pts)>1:
            s += f'<polyline points="{" ".join(pts)}" fill="none" stroke="{col}" stroke-width="2" opacity="0.8"/>\n'
    s += f'<text x="{px+pw//2}" y="{py+ph+35}" text-anchor="middle" class="axis-label">x</text>\n'
    s += f'<text x="{px-45}" y="{py+ph//2}" text-anchor="middle" class="axis-label" transform="rotate(-90,{px-45},{py+ph//2})">y</text>\n'
    s += '</svg>\n'
    return s

def generate_orbits():
    W, H = 700, 450
    s = svg_header(W, H, "Diagonal Map: d(z) = exp(z) − ln(z)")
    px, py, pw, ph = 80, 55, 560, 340
    s += f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="#fafafa" stroke="#ddd"/>\n'
    zr, dr = (0.1, 4), (0, 12)
    def sx(z): return px + (z-zr[0])/(zr[1]-zr[0])*pw
    def sy(d): return py + ph - (d-dr[0])/(dr[1]-dr[0])*ph
    pts = []
    for i in range(300):
        z = zr[0]+(zr[1]-zr[0])*i/299
        d = math.exp(z)-math.log(z)
        if dr[0]<=d<=dr[1]: pts.append(f"{sx(z):.1f},{sy(d):.1f}")
    s += f'<polyline points="{" ".join(pts)}" fill="none" stroke="#e74c3c" stroke-width="2.5"/>\n'
    id_pts = [f"{sx(z):.1f},{sy(z):.1f}" for z in [zr[0]+i*(zr[1]-zr[0])/99 for i in range(100)] if dr[0]<=z<=dr[1]]
    s += f'<polyline points="{" ".join(id_pts)}" fill="none" stroke="#3498db" stroke-width="1.5" stroke-dasharray="6,4"/>\n'
    s += f'<line x1="{px}" y1="{sy(2):.0f}" x2="{px+pw}" y2="{sy(2):.0f}" stroke="#2ecc71" stroke-width="1" stroke-dasharray="4,3"/>\n'
    w1 = 0.5671
    dm = math.exp(w1)-math.log(w1)
    s += f'<circle cx="{sx(w1):.0f}" cy="{sy(dm):.0f}" r="5" fill="#e74c3c"/>\n'
    s += f'<text x="{sx(w1)+8:.0f}" y="{sy(dm)-8:.0f}" class="annotation">min at W(1)≈0.567</text>\n'
    s += f'<text x="{px+10}" y="{py+20}" class="annotation">d(z) &gt; z for all z ✓</text>\n'
    s += f'<text x="{px+pw//2}" y="{py+ph+35}" text-anchor="middle" class="axis-label">z</text>\n'
    s += '</svg>\n'
    return s

def generate_etower():
    W, H = 700, 400
    s = svg_header(W, H, "E-Tower Growth: e↑↑n (Superexponential)")
    px, py, pw, ph = 100, 55, 540, 290
    s += f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="#fafafa" stroke="#ddd"/>\n'
    towers = [1.0]
    for _ in range(5):
        try:
            towers.append(math.exp(towers[-1]))
        except OverflowError:
            towers.append(1e308)
            break
    logs = [math.log10(max(t,0.1)) for t in towers]
    ml = max(logs)
    bw = pw/(len(towers)+1)
    cols = ['#3498db','#2ecc71','#e67e22','#e74c3c','#9b59b6','#1abc9c']
    for i,(t,lt) in enumerate(zip(towers,logs)):
        bx = px+(i+0.5)*bw
        bh = max(5,lt/max(ml,1)*ph)
        by_ = py+ph-bh
        s += f'<rect x="{bx:.0f}" y="{by_:.0f}" width="{bw*0.7:.0f}" height="{bh:.0f}" fill="{cols[i%6]}" rx="3" opacity="0.85"/>\n'
        s += f'<text x="{bx+bw*0.35:.0f}" y="{py+ph+15}" text-anchor="middle" class="tick">e↑↑{i}</text>\n'
        lbl = f"{t:.1f}" if t<1e6 else f"≈10^{lt:.0f}"
        s += f'<text x="{bx+bw*0.35:.0f}" y="{by_-5:.0f}" text-anchor="middle" class="label">{lbl}</text>\n'
    s += f'<text x="{px+pw-10}" y="{py+20}" text-anchor="end" class="annotation">e↑↑(n+2) ≥ exp(2ⁿ) ✓</text>\n'
    s += '</svg>\n'
    return s

def generate_fixedpoint():
    W, H = 700, 450
    s = svg_header(W, H, "Fixed Point: g(z) = e − ln(z), cobweb convergence")
    px, py, pw, ph = 80, 55, 560, 340
    s += f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="#fafafa" stroke="#ddd"/>\n'
    zr = (0.5, 4)
    def sx(z): return px+(z-zr[0])/(zr[1]-zr[0])*pw
    def sy(g): return py+ph-(g-zr[0])/(zr[1]-zr[0])*ph
    pts = []
    for i in range(300):
        z = zr[0]+(zr[1]-zr[0])*i/299
        g = math.e-math.log(z)
        if zr[0]<=g<=zr[1]: pts.append(f"{sx(z):.1f},{sy(g):.1f}")
    s += f'<polyline points="{" ".join(pts)}" fill="none" stroke="#e74c3c" stroke-width="2.5"/>\n'
    id_pts = [f"{sx(z):.1f},{sy(z):.1f}" for z in [zr[0]+i*(zr[1]-zr[0])/99 for i in range(100)] if zr[0]<=z<=zr[1]]
    s += f'<polyline points="{" ".join(id_pts)}" fill="none" stroke="#3498db" stroke-width="1.5" stroke-dasharray="6,4"/>\n'
    z = 1.0
    cob = []
    for _ in range(12):
        gz = math.e-math.log(z)
        cob.append(f"{sx(z):.1f},{sy(gz):.1f}")
        cob.append(f"{sx(gz):.1f},{sy(gz):.1f}")
        z = gz
    s += f'<polyline points="{" ".join(cob)}" fill="none" stroke="#2ecc71" stroke-width="1.2" opacity="0.7"/>\n'
    zs = 2.0171
    s += f'<circle cx="{sx(zs):.0f}" cy="{sy(zs):.0f}" r="6" fill="none" stroke="#e74c3c" stroke-width="2"/>\n'
    s += f'<circle cx="{sx(zs):.0f}" cy="{sy(zs):.0f}" r="2" fill="#e74c3c"/>\n'
    s += f'<text x="{sx(zs)+10:.0f}" y="{sy(zs)-10:.0f}" class="annotation">z* = W(eᵉ) ≈ 2.017</text>\n'
    s += f'<text x="{px+10}" y="{py+20}" class="annotation">|g\'(z*)| = 1/z* &lt; 1 (attracting)</text>\n'
    s += '</svg>\n'
    return s

def generate_amgm():
    W, H = 700, 450
    s = svg_header(W, H, "AM-GM Bridge: f(t) = t − ln(t) ≥ 1")
    px, py, pw, ph = 80, 55, 560, 340
    s += f'<rect x="{px}" y="{py}" width="{pw}" height="{ph}" fill="#fafafa" stroke="#ddd"/>\n'
    tr, fr = (0.05, 5), (0, 6)
    def sx(t): return px+(t-tr[0])/(tr[1]-tr[0])*pw
    def sy(f): return py+ph-(f-fr[0])/(fr[1]-fr[0])*ph
    pts = []
    shade = [f"{sx(tr[0]):.1f},{sy(1):.1f}"]
    for i in range(400):
        t = tr[0]+(tr[1]-tr[0])*i/399
        f = t-math.log(t)
        if fr[0]<=f<=fr[1]:
            pts.append(f"{sx(t):.1f},{sy(f):.1f}")
            shade.append(f"{sx(t):.1f},{sy(f):.1f}")
    shade.append(f"{sx(tr[1]):.1f},{sy(1):.1f}")
    s += f'<polygon points="{" ".join(shade)}" fill="#3498db" opacity="0.1"/>\n'
    s += f'<polyline points="{" ".join(pts)}" fill="none" stroke="#e74c3c" stroke-width="2.5"/>\n'
    s += f'<line x1="{px}" y1="{sy(1):.0f}" x2="{px+pw}" y2="{sy(1):.0f}" stroke="#3498db" stroke-width="1.5" stroke-dasharray="6,4"/>\n'
    s += f'<circle cx="{sx(1):.0f}" cy="{sy(1):.0f}" r="5" fill="#e74c3c"/>\n'
    s += f'<text x="{sx(1)+8:.0f}" y="{sy(1)+18:.0f}" class="annotation">min at t=1: f(1)=1</text>\n'
    s += f'<text x="{px+pw-10}" y="{py+20}" text-anchor="end" class="annotation">AM-GM: a+b−ln(a)−ln(b) ≥ 2</text>\n'
    s += f'<text x="{px+pw//2}" y="{py+ph+35}" text-anchor="middle" class="axis-label">t</text>\n'
    s += '</svg>\n'
    return s

def generate_overview():
    W, H = 800, 600
    s = svg_header(W, H, "The EML Operator: A Map of Connections")
    cx, cy = 400, 300
    s += f'<circle cx="{cx}" cy="{cy}" r="60" fill="#e74c3c" opacity="0.9"/>\n'
    s += f'<text x="{cx}" y="{cy-8}" text-anchor="middle" fill="white" style="font:bold 20px sans-serif">eml(x,y)</text>\n'
    s += f'<text x="{cx}" y="{cy+12}" text-anchor="middle" fill="white" style="font:14px sans-serif">= eˣ − ln(y)</text>\n'
    topics = [
        (180,100,"#3498db","Monotonicity","∂/∂x > 0, ∂/∂y < 0"),
        (620,100,"#2ecc71","E-Tower","e↑↑n → ∞"),
        (100,300,"#9b59b6","Magma","¬comm, ¬assoc, ..."),
        (700,300,"#e67e22","AM-GM Bridge","a+b−ln a−ln b ≥ 2"),
        (180,500,"#1abc9c","Fixed Points","z* = W(eᵉ)"),
        (620,500,"#34495e","Complexity","K(ln) = ?"),
        (400,100,"#c0392b","Tropical","max(x, −y)"),
        (400,500,"#16a085","Involution","f∘f = id"),
    ]
    for tx,ty,col,title,sub in topics:
        s += f'<rect x="{tx-70}" y="{ty-25}" width="140" height="50" fill="{col}" rx="8" opacity="0.85"/>\n'
        s += f'<text x="{tx}" y="{ty-5}" text-anchor="middle" fill="white" style="font:bold 13px sans-serif">{title}</text>\n'
        s += f'<text x="{tx}" y="{ty+13}" text-anchor="middle" fill="white" style="font:10px sans-serif">{sub}</text>\n'
        dx,dy = cx-tx,cy-ty
        d = math.sqrt(dx*dx+dy*dy)
        if d>0:
            nx,ny = dx/d,dy/d
            x1,y1 = tx+nx*75, ty+ny*30
            x2,y2 = cx-nx*65, cy-ny*65
            s += f'<line x1="{x1:.0f}" y1="{y1:.0f}" x2="{x2:.0f}" y2="{y2:.0f}" stroke="{col}" stroke-width="1.5" opacity="0.5" stroke-dasharray="4,3"/>\n'
    s += '</svg>\n'
    return s

if __name__ == "__main__":
    os.makedirs("visuals", exist_ok=True)
    svgs = {
        "visuals/eml_level_sets.svg": generate_level_sets(),
        "visuals/eml_diagonal_orbits.svg": generate_orbits(),
        "visuals/eml_etower_growth.svg": generate_etower(),
        "visuals/eml_fixedpoint.svg": generate_fixedpoint(),
        "visuals/eml_amgm_bridge.svg": generate_amgm(),
        "visuals/eml_overview.svg": generate_overview(),
    }
    for fn, content in svgs.items():
        with open(fn, 'w') as f:
            f.write(content)
        print(f"Generated: {fn}")
    print(f"\n{len(svgs)} SVGs generated in visuals/")
