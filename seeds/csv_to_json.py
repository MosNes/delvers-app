import csv
import json
from pathlib import Path

input_file = "artifacts.csv"
output_file = "artifact_seed.json"

path = Path(__file__).with_name(input_file)
out = Path(__file__).with_name(output_file)

rows = []
with path.open(newline="", encoding="utf-8") as f:
    reader = csv.reader(f)
    next(reader)  # header: name,source,description,effect,effect (last col = slots)
    for row in reader:
        if len(row) < 5:
            raise ValueError(f"Expected 5 columns, got {len(row)}: {row!r}")
        rows.append(
            {
                "name": row[0],
                "source": row[1],
                "description": row[2],
                "effect": row[3],
                "slots": int(row[4]),
                "isMinor": int(row[5]),
                "hasDepletion": int(row[6]),
                "depletionDie": row[7],
                "depletionResult": row[8],
            }
        )

out.write_text(json.dumps(rows, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {len(rows)} objects to {out}")
