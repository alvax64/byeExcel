# Entry module. The server import below is what registers each endpoint at
# /function/<name> - every new def:pub in api.jac must be added here too.

import from api { upload_workbook, workbooks_view, proposal_view }

import ".styles.global.css";
import from .ReviewShell { ReviewShell }

def:pub app -> JsxElement {
    return <ReviewShell/>;
}
