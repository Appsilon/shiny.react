import { join } from 'path';

export default {
  mode: 'development',
  output: {
    path: join(__dirname, '..', 'inst', 'www', 'shiny.react'),
    filename: 'shiny-react.js',
  },
  resolve: { extensions: ['.js', '.jsx', '.jsx', '.tsx', '.ts'] },
  module: {
    rules: [
      // All files with a '.ts' or '.tsx' extension will be handled by 'ts-loader'.
      { test: /\.tsx?$/, loader: "ts-loader" },
      { test: /\.(js|jsx)$/, use: ['babel-loader'] },
    ],
  },
  externals: {
    'react': 'React',
    'react-dom/client': 'ReactDOM',
  },
  stats: { colors: true },
  devtool: 'source-map',
};
