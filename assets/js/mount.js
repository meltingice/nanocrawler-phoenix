import React from "react";
import { TickerProvider } from "lib/TickerContext";
import { TranslationProvider } from "lib/TranslationContext";
import { NetworkProvider } from "lib/NetworkContext";
import { Router } from "react-router-dom";

import { createBrowserHistory } from "history";

const history = createBrowserHistory();
history.listen(location => {
  if (window.ga) {
    console.log("tracking page view: " + location.pathname);
    window.ga("set", "page", location.pathname);
    window.ga("send", "pageview");
  } else {
    console.log("GA unavailable");
  }
});

import App from "./App";

const Mount = () => (
  <TranslationProvider>
    <TickerProvider>
      <NetworkProvider>
        <Router history={history}>
          <App />
        </Router>
      </NetworkProvider>
    </TickerProvider>
  </TranslationProvider>
);

export default Mount;
