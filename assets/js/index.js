import "@babel/polyfill";
import "react-phoenix";
import "whatwg-fetch";

import "bootstrap/dist/css/bootstrap.css";
import "primer-tooltips/build/build.css";
import "./index.css";

import Mount from "./mount";

window.Components = {
  App: Mount
};
