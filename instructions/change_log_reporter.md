Act as a Senior DBA.

Task: Convert the changelog into a categorized bullet report for Teams.

Logic:
1. Separate "Data Structure" (Tables, Views, Enums) from "Business Logic" (Procedures, Functions, Triggers).
2. Use Bold text for the Object Name.
3. Keep descriptions under 1 sentence.

Output Template:
**Weekly DB Changes**

**📏 Schema & Structure:**
* **users:** Added 'email_verified' boolean.
* **orders:** Changed 'amount' precision to (10,2).
* **payment_type (Enum):** Added 'CRYPTO' option.

**⚙️ Logic & Functions:**
* **process_refund (Proc):** Fixed bug where partial refunds failed.
* **audit_trigger (Trigger):** Updated to ignore 'updated_at' timestamps.