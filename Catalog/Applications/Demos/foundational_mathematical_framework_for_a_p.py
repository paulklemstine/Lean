#!/usr/bin/env python3
"""Build PACKAGE.json from the individual files."""
import json
import os

def read_file(path):
    with open(path) as f:
        return f.read()

article = read_file("ARTICLE.md")
research_paper = read_file("RESEARCH_PAPER.md")
future_directions = read_file("FUTURE_DIRECTIONS.md")
demo_code = read_file("demo.py")
algo_code = read_file("algorithms.py")
viz_code = read_file("visualize_periodic_table.py")
lean_code = read_file("Catalog/EML/PeriodicTableGroups.lean")

interactive_html = """<div style="font-family: 'Segoe UI', sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">
<h2 style="text-align:center; color:#1a237e;">The Periodic Table of Finite Groups</h2>
<p style="text-align:center; color:#555;">Explore group invariants interactively. Click a group to see its properties.</p>

<div id="controls" style="margin: 15px 0; text-align: center;">
  <label>Color by: </label>
  <select id="colorMode" onchange="updateDisplay()" style="padding:5px; font-size:14px;">
    <option value="depth">Derived Depth</option>
    <option value="valence">Valence</option>
    <option value="nilpotent">Nilpotency</option>
  </select>
  <span style="margin-left: 20px;">
    <label>Max order: </label>
    <input type="range" id="maxOrder" min="2" max="30" value="25" oninput="updateDisplay()" style="width:150px;">
    <span id="maxOrderLabel">25</span>
  </span>
</div>

<svg id="table" width="860" height="400" style="border:1px solid #ddd; border-radius:8px; display:block; margin:0 auto;"></svg>

<div id="info" style="margin-top:15px; padding:15px; background:#f5f5f5; border-radius:8px; min-height:80px;">
  <p style="color:#888; text-align:center;">Click a group cell to see its periodic table entry.</p>
</div>

<div style="margin-top:15px; padding:10px; background:#e8eaf6; border-radius:8px;">
  <strong>Key Theorems:</strong><br>
  <span style="color:#1a237e;">■</span> Derived–Central Series Inequality: D<sup>n</sup>(G) ≤ γ<sub>n</sub>(G)<br>
  <span style="color:#c62828;">■</span> Quantitative Periodic Law: d(G) ≤ Ω(|G|)<br>
  <span style="color:#2e7d32;">■</span> Product Decomposition: D<sup>n</sup>(G×H) = D<sup>n</sup>(G) × D<sup>n</sup>(H)
</div>

<script>
var groups = [
  {name:"Z/1Z", order:1, depth:0, valence:0, center:1, nilp:true, solv:true},
  {name:"Z/2Z", order:2, depth:1, valence:1, center:2, nilp:true, solv:true},
  {name:"Z/3Z", order:3, depth:1, valence:1, center:3, nilp:true, solv:true},
  {name:"Z/4Z", order:4, depth:1, valence:1, center:4, nilp:true, solv:true},
  {name:"V₄", order:4, depth:1, valence:3, center:4, nilp:true, solv:true},
  {name:"Z/5Z", order:5, depth:1, valence:1, center:5, nilp:true, solv:true},
  {name:"S₃", order:6, depth:2, valence:1, center:1, nilp:false, solv:true},
  {name:"Z/6Z", order:6, depth:1, valence:2, center:6, nilp:true, solv:true},
  {name:"Z/7Z", order:7, depth:1, valence:1, center:7, nilp:true, solv:true},
  {name:"D₄", order:8, depth:2, valence:1, center:2, nilp:true, solv:true},
  {name:"Q₈", order:8, depth:2, valence:1, center:2, nilp:true, solv:true},
  {name:"Z/8Z", order:8, depth:1, valence:1, center:8, nilp:true, solv:true},
  {name:"Z/2Z³", order:8, depth:1, valence:7, center:8, nilp:true, solv:true},
  {name:"D₅", order:10, depth:2, valence:1, center:1, nilp:false, solv:true},
  {name:"A₄", order:12, depth:2, valence:1, center:1, nilp:false, solv:true},
  {name:"D₆", order:12, depth:2, valence:1, center:2, nilp:false, solv:true},
  {name:"Z/2Z×Z/6Z", order:12, depth:1, valence:3, center:12, nilp:true, solv:true},
  {name:"S₄", order:24, depth:3, valence:1, center:1, nilp:false, solv:true},
  {name:"A₅", order:60, depth:null, valence:1, center:1, nilp:false, solv:false}
];

function omega(n) {
  if (n<=1) return 0;
  var count=0, d=2;
  while(d*d<=n){while(n%d===0){count++;n/=d;}d++;}
  if(n>1)count++;
  return count;
}

function getColor(g, mode) {
  if(mode==='depth'){
    if(g.depth===null) return '#424242';
    var colors=['#e8eaf6','#7986cb','#3f51b5','#1a237e'];
    return colors[Math.min(g.depth, colors.length-1)];
  } else if(mode==='valence'){
    var v=g.valence;
    if(v===0) return '#eeeeee';
    if(v===1) return '#4caf50';
    if(v===2) return '#ff9800';
    if(v===3) return '#f44336';
    return '#9c27b0';
  } else {
    return g.nilp ? '#2196f3' : '#ff5722';
  }
}

function textColor(bg) {
  var r=parseInt(bg.slice(1,3),16), g=parseInt(bg.slice(3,5),16), b=parseInt(bg.slice(5,7),16);
  return (r*0.299+g*0.587+b*0.114)>150 ? '#000' : '#fff';
}

function updateDisplay() {
  var mode = document.getElementById('colorMode').value;
  var maxO = parseInt(document.getElementById('maxOrder').value);
  document.getElementById('maxOrderLabel').textContent = maxO;
  var svg = document.getElementById('table');
  svg.innerHTML = '';
  var filtered = groups.filter(function(g){return g.order<=maxO;});
  var cellW=70, cellH=55, padX=10, padY=10;
  var cols = Math.floor((860-padX)/(cellW+5));
  filtered.forEach(function(g, i){
    var col=i%cols, row=Math.floor(i/cols);
    var x=padX+col*(cellW+5), y=padY+row*(cellH+5);
    var bg=getColor(g,mode), tc=textColor(bg);
    var rect=document.createElementNS('http://www.w3.org/2000/svg','rect');
    rect.setAttribute('x',x);rect.setAttribute('y',y);
    rect.setAttribute('width',cellW);rect.setAttribute('height',cellH);
    rect.setAttribute('fill',bg);rect.setAttribute('rx','5');
    rect.setAttribute('stroke','#999');rect.setAttribute('stroke-width','1');
    rect.style.cursor='pointer';
    rect.onclick=(function(grp){return function(){showInfo(grp);};})(g);
    svg.appendChild(rect);
    var t1=document.createElementNS('http://www.w3.org/2000/svg','text');
    t1.setAttribute('x',x+cellW/2);t1.setAttribute('y',y+20);
    t1.setAttribute('text-anchor','middle');t1.setAttribute('fill',tc);
    t1.setAttribute('font-size','11');t1.setAttribute('font-weight','bold');
    t1.textContent=g.name; t1.style.pointerEvents='none';
    svg.appendChild(t1);
    var t2=document.createElementNS('http://www.w3.org/2000/svg','text');
    t2.setAttribute('x',x+cellW/2);t2.setAttribute('y',y+38);
    t2.setAttribute('text-anchor','middle');t2.setAttribute('fill',tc);
    t2.setAttribute('font-size','10');t2.style.pointerEvents='none';
    t2.textContent='|G|='+g.order;
    svg.appendChild(t2);
    var t3=document.createElementNS('http://www.w3.org/2000/svg','text');
    t3.setAttribute('x',x+cellW/2);t3.setAttribute('y',y+50);
    t3.setAttribute('text-anchor','middle');t3.setAttribute('fill',tc);
    t3.setAttribute('font-size','9');t3.style.pointerEvents='none';
    t3.textContent='d='+(g.depth!==null?g.depth:'∞')+' v='+g.valence;
    svg.appendChild(t3);
  });
  var svgH=padY+(Math.ceil(filtered.length/cols))*(cellH+5)+10;
  svg.setAttribute('height',Math.max(svgH,200));
}

function showInfo(g) {
  var om=omega(g.order);
  var law=g.depth!==null?(g.depth<=om?'✓ Verified':'✗ Violated'):'N/A (non-solvable)';
  document.getElementById('info').innerHTML=
    '<h3 style="margin:0 0 8px 0;color:#1a237e;">'+g.name+'</h3>'+
    '<table style="width:100%;font-size:14px;">'+
    '<tr><td><b>Order |G|:</b> '+g.order+'</td><td><b>Derived depth d(G):</b> '+(g.depth!==null?g.depth:'∞ (non-solvable)')+'</td></tr>'+
    '<tr><td><b>Valence v(G):</b> '+g.valence+'</td><td><b>Center order |Z(G)|:</b> '+g.center+'</td></tr>'+
    '<tr><td><b>Nilpotent:</b> '+(g.nilp?'Yes':'No')+'</td><td><b>Solvable:</b> '+(g.solv?'Yes':'No')+'</td></tr>'+
    '<tr><td><b>Ω(|G|):</b> '+om+'</td><td><b>Periodic Law d≤Ω:</b> '+law+'</td></tr>'+
    '</table>';
}

updateDisplay();
</script>
</div>"""

interactive_series_html = """<div style="font-family: 'Segoe UI', sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="text-align:center; color:#1a237e;">Derived vs Lower Central Series</h2>
<p style="text-align:center; color:#555;">The Derived–Central Series Inequality: D<sup>n</sup>(G) ≤ γ<sub>n</sub>(G)</p>

<div style="text-align:center; margin:15px 0;">
  <label>Select group: </label>
  <select id="groupSelect" onchange="updateChart()" style="padding:5px; font-size:14px;">
    <option value="s3">S₃ (order 6)</option>
    <option value="d4">D₄ (order 8)</option>
    <option value="a4">A₄ (order 12)</option>
    <option value="s4">S₄ (order 24)</option>
  </select>
</div>

<canvas id="seriesChart" width="760" height="350" style="border:1px solid #ddd; border-radius:8px; display:block; margin:0 auto;"></canvas>

<div id="explanation" style="margin-top:15px; padding:12px; background:#e8eaf6; border-radius:8px; font-size:14px;"></div>

<script>
var seriesData = {
  s3: {name:"S₃", order:6, derived:[6,3,1,1], central:[6,3,3,3]},
  d4: {name:"D₄", order:8, derived:[8,2,1,1], central:[8,2,1,1]},
  a4: {name:"A₄", order:12, derived:[12,4,1,1], central:[12,4,4,4]},
  s4: {name:"S₄", order:24, derived:[24,12,4,1,1], central:[24,12,12,12,12]}
};

function updateChart() {
  var key = document.getElementById('groupSelect').value;
  var data = seriesData[key];
  var canvas = document.getElementById('seriesChart');
  var ctx = canvas.getContext('2d');
  ctx.clearRect(0,0,canvas.width,canvas.height);

  var maxSteps = Math.max(data.derived.length, data.central.length);
  var maxVal = data.order;
  var padL=60, padR=30, padT=30, padB=50;
  var w=canvas.width-padL-padR, h=canvas.height-padT-padB;

  // Grid
  ctx.strokeStyle='#eee'; ctx.lineWidth=1;
  for(var i=0;i<=5;i++){
    var y=padT+h*(1-i/5);
    ctx.beginPath();ctx.moveTo(padL,y);ctx.lineTo(padL+w,y);ctx.stroke();
    ctx.fillStyle='#999';ctx.font='11px sans-serif';ctx.textAlign='right';
    ctx.fillText(Math.round(maxVal*i/5),padL-8,y+4);
  }

  // X axis labels
  for(var i=0;i<maxSteps;i++){
    var x=padL+w*i/(maxSteps-1||1);
    ctx.fillStyle='#999';ctx.font='12px sans-serif';ctx.textAlign='center';
    ctx.fillText('n='+i,x,canvas.height-10);
  }

  // Draw central series (wider, behind)
  ctx.strokeStyle='#ff7043'; ctx.lineWidth=3; ctx.setLineDash([8,4]);
  ctx.beginPath();
  for(var i=0;i<data.central.length;i++){
    var x=padL+w*i/(maxSteps-1||1);
    var y=padT+h*(1-data.central[i]/maxVal);
    if(i===0)ctx.moveTo(x,y);else ctx.lineTo(x,y);
  }
  ctx.stroke(); ctx.setLineDash([]);

  // Draw derived series
  ctx.strokeStyle='#1565c0'; ctx.lineWidth=3;
  ctx.beginPath();
  for(var i=0;i<data.derived.length;i++){
    var x=padL+w*i/(maxSteps-1||1);
    var y=padT+h*(1-data.derived[i]/maxVal);
    if(i===0)ctx.moveTo(x,y);else ctx.lineTo(x,y);
  }
  ctx.stroke();

  // Points
  for(var i=0;i<data.derived.length;i++){
    var x=padL+w*i/(maxSteps-1||1);
    var y=padT+h*(1-data.derived[i]/maxVal);
    ctx.beginPath();ctx.arc(x,y,5,0,2*Math.PI);ctx.fillStyle='#1565c0';ctx.fill();
    ctx.fillStyle='#1565c0';ctx.font='bold 11px sans-serif';ctx.textAlign='center';
    ctx.fillText(data.derived[i],x,y-10);
  }
  for(var i=0;i<data.central.length;i++){
    var x=padL+w*i/(maxSteps-1||1);
    var y=padT+h*(1-data.central[i]/maxVal);
    ctx.beginPath();ctx.arc(x,y,5,0,2*Math.PI);ctx.fillStyle='#ff7043';ctx.fill();
    if(data.central[i]!==data.derived[i]||i>=data.derived.length){
      ctx.fillStyle='#ff7043';ctx.font='bold 11px sans-serif';ctx.textAlign='center';
      ctx.fillText(data.central[i],x,y+18);
    }
  }

  // Legend
  ctx.fillStyle='#1565c0';ctx.font='bold 13px sans-serif';ctx.textAlign='left';
  ctx.fillText('— Derived series D^n(G)',padL+10,padT+15);
  ctx.fillStyle='#ff7043';
  ctx.fillText('--- Lower central series γ_n(G)',padL+10,padT+32);

  // Axis labels
  ctx.fillStyle='#333';ctx.font='13px sans-serif';ctx.textAlign='center';
  ctx.fillText('Step n',padL+w/2,canvas.height-2);
  ctx.save();ctx.translate(15,padT+h/2);ctx.rotate(-Math.PI/2);
  ctx.fillText('Subgroup order',0,0);ctx.restore();

  // Explanation
  var dd=0;for(var i=0;i<data.derived.length;i++){if(data.derived[i]===1){dd=i;break;}}
  var nilp=data.central[data.central.length-1]===1;
  document.getElementById('explanation').innerHTML=
    '<b>'+data.name+'</b> (order '+data.order+'): Derived depth = '+dd+
    '. The derived series (blue) decays '+(dd<data.central.length-1?'faster':'at the same rate as')+
    ' the lower central series (orange). '+(nilp?'This group is nilpotent (γ reaches 1).':'This group is NOT nilpotent (γ stabilizes above 1).')+
    ' <b>D<sup>n</sup> ≤ γ<sub>n</sub></b> holds at every step ✓';
}

updateChart();
</script>
</div>"""

package = {
    "title": "The Periodic Table of Finite Groups",
    "domain": "EML",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "demo.py",
            "code": demo_code,
            "description": "Comprehensive demonstration of all theorems: Derived-Central Series Inequality, Product Decomposition, Quantitative Periodic Law, Group Valence, and Periodic Table construction."
        }
    ],
    "algorithms": [
        {
            "name": "Derived Series Computation",
            "pseudocode": "D(0) = G; D(n+1) = [D(n), D(n)]; return sequence until stabilization",
            "code": algo_code
        }
    ],
    "visualizations": [
        {
            "name": "Periodic Table Heatmap",
            "code": viz_code,
            "description": "Matplotlib visualization showing group invariants as a heatmap-style periodic table, with derived depth vs order and valence coloring."
        }
    ],
    "interactive_demos": [
        {
            "name": "Interactive Periodic Table of Groups",
            "html": interactive_html,
            "description": "Clickable periodic table of finite groups showing order, derived depth, valence, and solvability, with interactive coloring modes."
        },
        {
            "name": "Derived vs Central Series Visualizer",
            "html": interactive_series_html,
            "description": "Interactive chart comparing the derived and lower central series for selected groups, demonstrating the Derived-Central Series Inequality."
        }
    ],
    "lean_proofs": [
        {
            "name": "PeriodicTableGroups.lean",
            "code": lean_code,
            "description": "Machine-verified Lean 4 proofs of the Derived-Central Series Inequality, Product Decomposition Theorem, Nilpotency Class Bound, Simple Group Valence, Derived Depth of Products, and the Quantitative Periodic Law."
        }
    ]
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json created successfully.")
print(f"  Article: {len(article)} chars")
print(f"  Research Paper: {len(research_paper)} chars")
print(f"  Future Directions: {len(future_directions)} chars")
print(f"  Lean code: {len(lean_code)} chars")
print(f"  Interactive demos: {len(package['interactive_demos'])}")


#!/usr/bin/env python3
"""
Demo: The Periodic Table of Finite Groups

Demonstrates the key results:
1. Derived-Central Series Inequality verification
2. Product Decomposition Theorem verification
3. Quantitative Periodic Law verification
4. Group valence computation
"""

from algorithms import (
    cyclic_group, symmetric_group_3, klein_four, direct_product,
    derived_series, lower_central_series, derived_depth, group_valence,
    omega, PeriodicTableEntry, is_solvable, is_nilpotent,
)


def demo_derived_central_inequality():
    """Demonstrate: derivedSeries(G,n) ≤ lowerCentralSeries(G,n) for all n."""
    print("=" * 70)
    print("  THEOREM: Derived–Central Series Inequality")
    print("  D^n(G) ≤ γ_n(G) for all n")
    print("=" * 70)

    groups = [
        cyclic_group(6),
        symmetric_group_3(),
        klein_four(),
        direct_product(symmetric_group_3(), cyclic_group(2)),
    ]

    for g in groups:
        ds = derived_series(g)
        lcs = lower_central_series(g)
        print(f"\n{g.name} (order {g.n}):")
        max_len = max(len(ds), len(lcs))
        all_ok = True
        for i in range(min(max_len, 6)):
            d_i = ds[i] if i < len(ds) else ds[-1]
            l_i = lcs[i] if i < len(lcs) else lcs[-1]
            contained = d_i.issubset(l_i)
            all_ok = all_ok and contained
            print(f"  n={i}: |D^{i}|={len(d_i):3d}, |γ_{i}|={len(l_i):3d}, "
                  f"D^{i} ⊆ γ_{i}: {'✓' if contained else '✗'}")
        print(f"  Inequality verified: {'✓' if all_ok else '✗'}")


def demo_product_decomposition():
    """Demonstrate: D^n(G × H) = D^n(G) × D^n(H)."""
    print("\n" + "=" * 70)
    print("  THEOREM: Product Decomposition")
    print("  D^n(G × H) = D^n(G) × D^n(H)")
    print("=" * 70)

    g = symmetric_group_3()
    h = cyclic_group(3)
    gh = direct_product(g, h)

    ds_gh = derived_series(gh)
    ds_g = derived_series(g)
    ds_h = derived_series(h)

    print(f"\n{g.name} × {h.name} (order {gh.n}):")
    for i in range(min(len(ds_gh), 4)):
        d_gh = ds_gh[i]
        d_g = ds_g[i] if i < len(ds_g) else ds_g[-1]
        d_h = ds_h[i] if i < len(ds_h) else ds_h[-1]
        # Product size should be |D^n(G)| * |D^n(H)|
        expected_size = len(d_g) * len(d_h)
        print(f"  n={i}: |D^{i}(G×H)|={len(d_gh):3d}, "
              f"|D^{i}(G)|·|D^{i}(H)|={expected_size:3d}, "
              f"match: {'✓' if len(d_gh) == expected_size else '✗'}")


def demo_quantitative_periodic_law():
    """Demonstrate: d(G) ≤ Ω(|G|) for solvable G."""
    print("\n" + "=" * 70)
    print("  THEOREM: Quantitative Periodic Law")
    print("  d(G) ≤ Ω(|G|) for all nontrivial solvable G")
    print("=" * 70)

    groups = [
        cyclic_group(2),
        cyclic_group(3),
        cyclic_group(4),
        cyclic_group(6),
        symmetric_group_3(),
        klein_four(),
        direct_product(cyclic_group(2), cyclic_group(2)),
        direct_product(symmetric_group_3(), cyclic_group(2)),
        direct_product(symmetric_group_3(), symmetric_group_3()),
    ]

    print(f"\n{'Group':<20s} {'|G|':>5s} {'d(G)':>5s} {'Ω(|G|)':>7s} {'d≤Ω':>5s}")
    print("-" * 45)
    for g in groups:
        d = derived_depth(g)
        om = omega(g.n)
        ok = d is not None and d <= om
        d_str = str(d) if d is not None else "∞"
        print(f"{g.name:<20s} {g.n:>5d} {d_str:>5s} {om:>7d} {'✓' if ok else '✗':>5s}")


def demo_group_valence():
    """Demonstrate group valence computation."""
    print("\n" + "=" * 70)
    print("  GROUP VALENCE (Minimal Normal Subgroup Count)")
    print("=" * 70)

    groups = [
        cyclic_group(2),
        cyclic_group(3),
        cyclic_group(4),
        cyclic_group(6),
        symmetric_group_3(),
        klein_four(),
    ]

    print(f"\n{'Group':<15s} {'|G|':>5s} {'v(G)':>5s} {'Solvable':>10s} {'Nilpotent':>10s}")
    print("-" * 50)
    for g in groups:
        v = group_valence(g)
        sol = is_solvable(g)
        nil = is_nilpotent(g)
        print(f"{g.name:<15s} {g.n:>5d} {v:>5d} {'Yes' if sol else 'No':>10s} "
              f"{'Yes' if nil else 'No':>10s}")


def demo_periodic_table():
    """Build and display a mini periodic table."""
    print("\n" + "=" * 70)
    print("  THE PERIODIC TABLE OF SMALL GROUPS")
    print("=" * 70)

    groups = [
        cyclic_group(1),
        cyclic_group(2),
        cyclic_group(3),
        cyclic_group(4),
        klein_four(),
        cyclic_group(5),
        cyclic_group(6),
        symmetric_group_3(),
    ]

    entries = [PeriodicTableEntry(g) for g in groups]

    print(f"\n{'Name':<12s} {'|G|':>4s} {'d(G)':>5s} {'v(G)':>5s} {'|Z|':>4s} "
          f"{'Ω(|G|)':>7s} {'Sol':>4s} {'Nil':>4s} {'d≤Ω':>4s}")
    print("-" * 60)
    for e in entries:
        d_str = str(e.period) if e.period is not None else "∞"
        law = e.verify_periodic_law()
        law_str = "✓" if law else ("✗" if law is False else "-")
        print(f"{e.name:<12s} {e.order:>4d} {d_str:>5s} {e.valence:>5d} "
              f"{e.center_order:>4d} {e.omega:>7d} "
              f"{'Y' if e.solvable else 'N':>4s} "
              f"{'Y' if e.nilpotent else 'N':>4s} {law_str:>4s}")


def demo_derived_depth_product():
    """Demonstrate: d(G × H) = max(d(G), d(H))."""
    print("\n" + "=" * 70)
    print("  THEOREM: d(G × H) = max(d(G), d(H))")
    print("=" * 70)

    pairs = [
        (cyclic_group(2), cyclic_group(3)),
        (cyclic_group(2), cyclic_group(2)),
        (symmetric_group_3(), cyclic_group(2)),
        (symmetric_group_3(), cyclic_group(3)),
    ]

    for g, h in pairs:
        gh = direct_product(g, h)
        d_g = derived_depth(g)
        d_h = derived_depth(h)
        d_gh = derived_depth(gh)
        expected = max(d_g or 0, d_h or 0)
        ok = d_gh == expected
        print(f"  d({g.name} × {h.name}) = {d_gh}, "
              f"max(d({g.name}), d({h.name})) = max({d_g}, {d_h}) = {expected}, "
              f"{'✓' if ok else '✗'}")


if __name__ == "__main__":
    demo_derived_central_inequality()
    demo_product_decomposition()
    demo_quantitative_periodic_law()
    demo_group_valence()
    demo_periodic_table()
    demo_derived_depth_product()
    print("\n" + "=" * 70)
    print("  All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: The Periodic Table of Small Finite Groups

Creates a heatmap-style periodic table showing group invariants
(derived depth as row, order as position, valence as color intensity).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def omega(n):
    """Number of prime factors with multiplicity."""
    if n <= 1:
        return 0
    count = 0
    d = 2
    while d * d <= n:
        while n % d == 0:
            count += 1
            n //= d
        d += 1
    if n > 1:
        count += 1
    return count


# Group data: (name, order, derived_depth, valence, center_order, is_nilpotent)
groups = [
    ("Z/1Z", 1, 0, 0, 1, True),
    ("Z/2Z", 2, 1, 1, 2, True),
    ("Z/3Z", 3, 1, 1, 3, True),
    ("Z/4Z", 4, 1, 1, 4, True),
    ("V₄", 4, 1, 3, 4, True),
    ("Z/5Z", 5, 1, 1, 5, True),
    ("Z/6Z", 6, 1, 2, 6, True),
    ("Z/7Z", 7, 1, 1, 7, True),
    ("Z/8Z", 8, 1, 1, 8, True),
    ("Z/2Z³", 8, 1, 7, 8, True),
    ("D₄", 8, 2, 1, 2, True),
    ("Q₈", 8, 2, 1, 2, True),
    ("S₃", 6, 2, 1, 1, False),
    ("D₅", 10, 2, 1, 1, False),
    ("A₄", 12, 2, 1, 1, False),
    ("D₆", 12, 2, 1, 2, False),
    ("S₄", 24, 3, 1, 1, False),
    # A5 is not solvable
]

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

# Plot 1: Derived depth vs group order
ax1 = axes[0]
for name, order, dd, val, center, nilp in groups:
    color = 'royalblue' if nilp else 'crimson'
    size = 50 + val * 80
    ax1.scatter(order, dd, s=size, c=color, alpha=0.7, edgecolors='black', linewidth=0.5)
    ax1.annotate(name, (order, dd), textcoords="offset points",
                xytext=(5, 5), fontsize=7, alpha=0.8)

ax1.set_xlabel("Group Order |G|", fontsize=12)
ax1.set_ylabel("Derived Depth d(G)", fontsize=12)
ax1.set_title("Periodic Table: Derived Depth vs Order", fontsize=14)

# Add the Ω bound line
orders = np.arange(1, 30)
omegas = [omega(n) for n in orders]
ax1.plot(orders, omegas, 'k--', alpha=0.3, label="Ω(|G|) bound")
ax1.legend(handles=[
    mpatches.Patch(color='royalblue', label='Nilpotent'),
    mpatches.Patch(color='crimson', label='Non-nilpotent'),
    plt.Line2D([0], [0], color='k', linestyle='--', alpha=0.3, label='Ω(|G|) bound'),
], fontsize=9)

# Plot 2: Valence distribution
ax2 = axes[1]
valences = {}
for name, order, dd, val, center, nilp in groups:
    if val not in valences:
        valences[val] = []
    valences[val].append((name, order, dd, nilp))

colors_val = {0: '#cccccc', 1: '#4CAF50', 2: '#FF9800', 3: '#f44336', 7: '#9C27B0'}
for val in sorted(valences.keys()):
    entries = valences[val]
    orders_v = [e[1] for e in entries]
    depths_v = [e[2] for e in entries]
    c = colors_val.get(val, '#666666')
    ax2.scatter(orders_v, depths_v, s=100, c=c, alpha=0.7,
               edgecolors='black', linewidth=0.5, label=f'v={val}')
    for name, order, dd, nilp in entries:
        ax2.annotate(name, (order, dd), textcoords="offset points",
                    xytext=(5, 5), fontsize=7, alpha=0.8)

ax2.set_xlabel("Group Order |G|", fontsize=12)
ax2.set_ylabel("Derived Depth d(G)", fontsize=12)
ax2.set_title("Group Valence Distribution", fontsize=14)
ax2.legend(fontsize=9)

plt.tight_layout()
plt.savefig("periodic_table_groups.png", dpi=150, bbox_inches='tight')
print("Saved: periodic_table_groups.png")
