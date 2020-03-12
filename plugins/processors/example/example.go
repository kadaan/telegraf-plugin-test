package example

import (
	"github.com/influxdata/telegraf"
	"github.com/influxdata/telegraf/plugins/processors"
	"log"
	"reflect"
)

type Example struct {
}

const sampleConfig = `
  # [[processors.example]]
  #   ## Nothing!!!
`
func (r *Example) SampleConfig() string {
	return sampleConfig
}

func (r *Example) Description() string {
	return "Example processor plugin"
}

func (r *Example) Apply(metrics ...telegraf.Metric) []telegraf.Metric {
	return metrics
}

func init() {
	log.Printf("I! [processors.example] init started")
	processors.Add("example",   func() telegraf.Processor {
		log.Printf("I! [processors.example] creating processor")
		processor :=  &Example{}
		log.Printf("I! [processors.example] creating processor")
		return processor
	})
	log.Printf("I! [processors.example] Processors (%v): ", reflect.ValueOf(processors.Processors).Pointer())
	for k := range processors.Processors {
		log.Printf("I! [processors.example]    Processor: %s", k)
	}
	log.Printf("I! [processors.example] init finish")
}