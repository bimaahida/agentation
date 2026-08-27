import * as React from "react";
import { Checkbox } from "../../../checkbox";
import { HelpTooltip } from "../../../help-tooltip";
import styles from "./styles.module.scss";

let idCounter = 0;

// ponytail: React < 18 has no useId. The counter is enough here because the
// toolbar is client-only (no SSR hydration to keep ids in sync with).
const useStableId: () => string =
  React.useId ?? (() => React.useState(() => `agentation-field-${++idCounter}`)[0]);

interface CheckboxFieldProps extends React.HTMLAttributes<HTMLDivElement> {
  label: string;
  tooltip?: string;
  checked?: boolean;
  onChange?: React.ChangeEventHandler<HTMLInputElement>;
}

export const CheckboxField = ({
  className = "",
  label,
  tooltip,
  checked,
  onChange,
  ...props
}: CheckboxFieldProps) => {
  const id = useStableId();

  return (
    <div className={`${styles.container} ${className}`} {...props}>
      <Checkbox id={id} onChange={onChange} checked={checked} />
      <label className={styles.label} htmlFor={id}>
        {label}
      </label>
      {tooltip && <HelpTooltip content={tooltip} />}
    </div>
  );
};
