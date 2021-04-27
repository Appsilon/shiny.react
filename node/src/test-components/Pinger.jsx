import { useState, useEffect, useRef } from 'react';
import propTypes from 'prop-types';

function useStateRef(x) {
  const ref = useRef();
  useEffect(() => {
    ref.current = x;
  }, [x]);
  return ref;
}

export default function Pinger({ immediate, interval, action }) {
  const [seq, setSeq] = useState(0);
  const seqRef = useStateRef(seq);

  useEffect(() => {
    function ping() {
      const next = seqRef.current + 1;
      if (action) action(next);
      setSeq(next);
    }
    if (immediate) ping();
    const id = setInterval(ping, interval);
    return () => clearInterval(id);
  }, []);

  return seq;
}

Pinger.propTypes = {
  immediate: propTypes.bool,
  interval: propTypes.number,
  action: propTypes.func,
};

Pinger.defaultProps = {
  immediate: false,
  interval: 1000,
  action: console.log, // eslint-disable-line no-console
};
