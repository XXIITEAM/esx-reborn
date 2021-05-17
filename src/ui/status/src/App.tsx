import React from "react";
import "./App.css";
import { useStatusService } from "./components/hooks/useStatusService";
import StatusCircle from "./components/StatusCircle";
import { useNuiService } from "./nui-events/hooks/useNuiService";


//setTimeout(() => {
//  window.dispatchEvent(
//    new MessageEvent("message", {
//      data: {
//        app: 'STATUS',
//        method: 'setStatus',
//        data: [
//          {
//            id: 1,
//            color: 'pink',
//            value: 50,
//            icon: 'fa-brain',
//            iconType: 'fontawesome',
//            fadeType: 'desc'
//          },
//          {
//            id: 2,
//            color: 'orange',
//            value: 75,
//            fadeType: 'desc',
//            icon: 'fastfood',
//            iconType: 'material'
//          }
//        ]
//      }
//    })
//  )
//}, 1000)

function App() {
  useNuiService();
  useStatusService();
  return (
    <div className="App">
      <StatusCircle />
    </div>
  );
}

export default App;
