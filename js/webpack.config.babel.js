import { join } from 'path';

export default {
  mode: 'development',
  output: {
    path: join(__dirname, '..', 'inst', 'www', 'shiny.react'),
    filename: 'shiny-react.js',
  },
  resolve: { extensions: ['.js', '.jsx'] },
  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        use: ['babel-loader'],
      },
    ],
  },
  externals: {
    '@/shiny': 'Shiny',
    'react': 'React',
    'react-dom': 'ReactDOM',
  },
  stats: { colors: true },
  devtool: 'source-map',
};
