const path = require("path");
const glob = require("glob");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    "./js/index.js": glob.sync("./vendor/**/*.js").concat(["./js/index.js"])
  },
  output: {
    publicPath: "/",
    filename: "js/app.js",
    chunkFilename: "js/[name].chunk.js",
    path: path.resolve(__dirname, "../priv/static")
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader"
        }
      },
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"]
      },
      {
        test: /\.(png|jpe?g|gif|svg)$/,
        use: [
          {
            loader: "file-loader",
            options: {
              name: "[name].[hash:8].[ext]",
              outputPath: "images"
            }
          }
        ]
      }
    ]
  },
  resolve: {
    modules: [
      path.resolve(__dirname, "./js"),
      path.resolve(__dirname, "./node_modules")
    ],
    alias: {
      react: path.resolve(__dirname, "./node_modules/react"),
      "react-dom": path.resolve(__dirname, "./node_modules/react-dom")
    }
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "../css/app.css",
      ignoreOrder: false
    }),
    new CopyWebpackPlugin([{ from: "static/", to: "../" }])
  ]
});
